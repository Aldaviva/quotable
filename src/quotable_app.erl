-module(quotable_app).
-behaviour(application).

-export([start/2, stop/1]).

-define(HTTPPORT, 8080).
-define(MONGOHOST, localhost).
-define(MONGOPORT, 27017).

start(_Type, _Args) ->
	Routes = gen_routes(),
	Dispatch = cowboy_router:compile(Routes),

	{ ok, _ } = cowboy:start_http(http, 100, [{ port, ?HTTPPORT }], [
		{env, [{ dispatch, Dispatch }]}
	]),

	io:format(<<"Listening on port ~B.~n">>, [ ?HTTPPORT ]),
	quotable_sup:start_link().

stop(_State) ->
	ok.

gen_routes() ->
	MongoConnection = connect_to_mongo(),
	StreamClientRegistry = spawn(fun() -> stream_client_registry([]) end),
	StaticOpts = [
		{directory, <<"public/media">>},
		{etag, {attributes, [filepath, filesize, inode, mtime]}},
		{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
	],
	[{'_', [
		{"/api/quotes/websocket", quotes_socket_handler, [StreamClientRegistry]},
		{"/api/quotes/eventstream", quotes_stream_handler, [StreamClientRegistry]},
		{"/api/quotes", listquotes_handler, [MongoConnection, StreamClientRegistry]},
		{"/", cowboy_static, [ {file, <<"../index.html">>} | StaticOpts ] },
		{"/media/[...]", cowboy_static, StaticOpts}
	]}].

connect_to_mongo() ->
	{ ok, Conn } = mongo:connect({ ?MONGOHOST, ?MONGOPORT }),
	io:format(<<"Connected to database.~n">>),
	Conn.

stream_client_registry(Clients) ->
	receive
		{From, add} ->
			stream_client_registry([ From | Clients ]);
		{From, list} ->
			From ! {list, Clients},
			stream_client_registry(Clients);
		{From, remove} ->
			stream_client_registry(lists:delete(From, Clients))
	end.
