-module(quotes_socket_handler).

-export([init/3, websocket_init/3, websocket_handle/3, websocket_info/3, websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, Opts) ->
	[StreamClientRegistry] = Opts,
	StreamClientRegistry ! {self(), add},
	State = Opts,
	{ok, Req, State, hibernate}.

websocket_handle(_Data, Req, State) ->
	% ignore messages from clients
	{ok, Req, State}.

websocket_info({quote_added, QuoteId, Body, Author}, Req, State) ->
	Data = {[{'_id', QuoteId}, {body, Body}, {author, Author}, {date, timestamp()}]},
	Msg = jiffy:encode(Data),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, State) ->
	[StreamClientRegistry] = State,
	StreamClientRegistry ! {self(), remove},
	ok.

timestamp() ->
	{Mega, Sec, _} = erlang:now(),
	Mega * 1000000 + Sec.