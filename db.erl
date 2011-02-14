-module(db).
-compile(export_all).
-author({jha, abhinav}).
-record(user, {username, password}).
-include_lib("stdlib/include/qlc.hrl").

init()->
    mnesia:create_schema([yawsnode@abhinav]),
    mnesia:start(),
    mnesia:create_table(user, [{attributes, record_info(fields, user)}, {disc_only_copies, [node()]}]).

insert(Username, Password)->
    G = fun() -> mnesia:write(#user{username=Username, password=Password}) end,
    mnesia:transaction(G).

read()->
    F = fun() -> qlc:e(qlc:q([X||X<-mnesia:table(user)])) end,
    {atomic, Val} = mnesia:transaction(F),
    io:format("~p~n", [Val]).

lookup(Username)->
    F = fun() -> qlc:e(qlc:q([X||X<-mnesia:table(user), X#user.username =:= Username])) end,
    case mnesia:transaction(F) of 
        {atomic, [H|_]} -> H#user.password;
        _-> "unauthorized"
    end.
