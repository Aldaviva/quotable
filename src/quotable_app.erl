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
	[
		{'_', [{"/quotes", listquotes_handler, [MongoConnection]}]}
	].

connect_to_mongo() ->
	{ ok, Conn } = mongo:connect({ ?MONGOHOST, ?MONGOPORT }),
	io:format(<<"Connected to database.~n">>),
	Conn.