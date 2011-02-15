-module(daemon).
-compile(export_all).
-author({jha, abhinav}).
-include("table.hrl").

start()->
    Users_online = db:fetch_online_users(),
    io:format("~p~n", [Users_online]),
    Processes = prespawn(Users_online, []),
    recv_loop(Processes).

check_online(From, Processes)->
    {User, _} = lists:keysearch(From, 2, Processes),
    Users = db:fetch_online_users(),
    lists:member(User, Users).


recv_loop(Processes)->
    receive
        {From, Msg}->
            case check_online(From, Processes) of 
                true ->
                    case Msg of 
                        nil -> From ! {self(), sleep, 30};
                        _ -> place_call(Msg),
                             From ! {self(), sleep, 1}
                    end;
                false ->
                    From ! {self(), kill}
            end;
        _ -> true
    end,
    recv_loop(Processes).


prespawn([], Processes) -> Processes;
prespawn([H|T], Processes)->
    process_flag(trap_exit, true),
    Parent = self(),
    Process = spawn_link(?MODULE, process_user, [H, Parent]),
    prespawn(T, [{H, Process}|Processes]).

process_user(User, Parent)->
    Key = User#user.key,
    % can't ack unless confirmed by the parent process.
    Msg = consume(Key),
    Parent ! {self(), Msg},
    receive
        {Parent, sleep, X} -> timer:sleep(X*1000);
        {Parent, die} -> exit(self(), "Asked to exit.");
        _ -> true
    end,
    process_user(User, Parent).

consume(Key)->rabbit_test:start_sub(Key).

place_call(_Msg)->
    % FS code here. 
    true.
