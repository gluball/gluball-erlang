-module(db).
-compile(export_all).
-author({jha, abhinav}).
-record(user, {username, password, email, online, key}).
-include_lib("stdlib/include/qlc.hrl").

init()->
    mnesia:create_schema([yawsnode@abhinav]),
    mnesia:start(),
    mnesia:create_table(user, [{attributes, record_info(fields, user)}, {ram_copies, [node()]}]).

insert(Username, Password, Email, Online)->
    G = fun() -> mnesia:write(#user{username=Username, password=Password, email=Email, online=Online}) end,
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

fetch_online_users()->
    F = fun() -> qlc:e(qlc:q([X||X<-mnesia:table(user), X#user.online =:= 1])) end,
    mnesia:transaction(F).
