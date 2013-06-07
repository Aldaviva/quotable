-module(quotes_stream_handler).

-export([init/3, info/3, terminate/3]).

init(_Transport, Req, [StreamClientRegistry]) ->
	Headers = [{<<"content-type">>, <<"text/event-stream">>}],
	{ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),
	StreamClientRegistry ! {self(), add},
	{loop, Req2, [StreamClientRegistry], 60000, hibernate}.

info({quote_added, QuoteId, Body, Author}, Req, State) ->
	Data = {[{'_id', QuoteId}, {body, Body}, {author, Author}, {date, timestamp()}]},
	Msg = jiffy:encode(Data),
	ok = cowboy_req:chunk(["id: ", id(), "\ndata: ", Msg, "\n\n"], Req),
	{loop, Req, State, hibernate}.

terminate(_Reason, _Req, [StreamClientRegistry]) ->
	StreamClientRegistry ! {self(), remove},
	ok.

id() ->
	{Mega, Sec, Micro} = erlang:now(),
	Id = (Mega * 1000000 + Sec) * 1000000 + Micro,
	integer_to_list(Id, 16).

timestamp() ->
	{Mega, Sec, _} = erlang:now(),
	Mega * 1000000 + Sec.