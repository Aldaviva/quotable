-module(addquote_handler).

-export([init/3, handle/2, terminate/3]).

init(_Transport, Req, [MongoConnection]) ->
	{ok, Req, [MongoConnection]}.

handle(Req, [MongoConnection]) ->
	{ok, Req2} = cowboy_req:reply(400, [], <<"not implemented">>, Req),
	{ok, Req2, [MongoConnection]}.

terminate(_Reason, _Req, _State) ->
	ok.