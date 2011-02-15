-module(rabbit_test).
-compile(export_all).

-include_lib("rabbitmq-erlang-client/include/amqp_client.hrl").

-define(X, <<"adexchange">>).
-define(RoutingKey, <<"gurgaon.realestate.#">>).
-define(RoutingKey2, <<"gurgaon.medicine.#">>).
-define(Q, <<"dummyuser">>).
-define(Q2, <<"dummyuser2">>).

%% -------------------------------------
%% SETUP QUEUE
%% -------------------------------------
setup_queue() ->
  %Node = hd(net_adm:ping('rabbit@abhinav')),
  {ok, Connection} = amqp_connection:start(network),
  {ok, Channel} = amqp_connection:open_channel(Connection),
  amqp_channel:call(Channel, #'exchange.declare'{exchange = ?X, type = <<"topic">>}),
  amqp_channel:call(Channel, #'queue.declare'{queue = ?Q}),
  amqp_channel:call(Channel, #'queue.declare'{queue = ?Q2}),
  Route = #'queue.bind'{queue = ?Q, exchange = ?X, routing_key = ?RoutingKey},
  Route2 = #'queue.bind'{queue = ?Q2, exchange = ?X, routing_key = ?RoutingKey2},
  amqp_channel:call(Channel, Route),
  amqp_channel:call(Channel, Route2),
  amqp_channel:close(Channel),
  amqp_connection:close(Connection),
  ok.
  
%% -------------------------------------
%% PUBLISHER
%% -------------------------------------
start_pub() ->
  proc_lib:start_link(?MODULE, init_pub, [self()]).
  
init_pub(Parent) ->
  {ok, Channel} = channel(),
  proc_lib:init_ack(Parent, {ok, self()}),
  loop_pub(Channel, <<"gurgaon.medicine.penicillin">>, <<"sale">>).
  
loop_pub(Channel, Key, Payload) ->
  Publish = #'basic.publish'{exchange = ?X, routing_key = Key},
  ok = amqp_channel:call(Channel, Publish, #amqp_msg{payload = Payload}),
  timer:sleep(10),
  loop_pub(Channel, <<"gurgaon.realestate.duplex">>, <<"nosale">>).

%% -------------------------------------
%% SUBSCRIBER
%% -------------------------------------
start_sub() ->
  proc_lib:start_link(?MODULE, init_sub, [self()]).

start_sub(Key)->
    {ok, Channel} = channel(),
    consume(Channel, Key).

consume(Channel, Key)->
    Msg = amqp_channel:call(Channel, #'basic.get'{queue=Key, no_ack=True}),
    Payload = decode(Msg),
    Payload.

init_sub(Parent) ->
  {ok, Channel} = channel(),
  proc_lib:init_ack(Parent, {ok, self()}),
  loop_sub(Channel, true, true).

loop_sub(_, false, false) -> done;
loop_sub(Channel, _, _) ->
  Msg = amqp_channel:call(Channel, #'basic.get'{queue = ?Q, no_ack = true}),
  Msg2 = amqp_channel:call(Channel, #'basic.get'{queue = ?Q2, no_ack = true}),
  Payload = decode(Msg),
  Payload2 = decode(Msg2),
  io:format("Msg from q = ~p~n", [Payload]),
  io:format("Msg from q2 = ~p~n", [Payload2]),
  loop_sub(Channel, Payload, Payload2).

%% -------------------------------------
%% UTIL FUNCTIONS
%% -------------------------------------  
rabbit_node() -> hd(nodes()).
  
channel() ->
  %Node = rabbit_node(),
  {ok,Connection} = amqp_connection:start(network),
  amqp_connection:open_channel(Connection).

length() ->
  Channel = channel(),
  {'queue.declare_ok', _, MC, _} = amqp_channel:call(Channel, #'queue.declare'{queue = ?Q}),
  MC.

decode(Msg)->
    case Msg of
        {_, {_, _, X}} -> X;
        _ -> false
    end.
