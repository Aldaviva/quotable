-module(quotes_stream_handler).

-export([init/3, info/3, terminate/3]).

init(_Transport, Req, [StreamClientRegistry]) ->
	Headers = [{<<"content-type">>, <<"text/event-stream">>}],
	{ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),
	StreamClientRegistry ! {self(), add},
	{loop, Req2, [StreamClientRegistry], 60000, hibernate}.

info({message, Msg}, Req, State) ->
	ok = cowboy_req:chunk(["id: ", id(), "\ndata: ", Msg, "\n\n"], Req),
	io:format("sent stream event"),
	{loop, Req, State, hibernate}.

terminate(_Reason, _Req, [StreamClientRegistry]) ->
	StreamClientRegistry ! {self(), remove},
	ok.

id() ->
	{Mega, Sec, Micro} = erlang:now(),
	Id = (Mega * 1000000 + Sec) * 1000000 + Micro,
	integer_to_list(Id, 16).