-module(listquotes_handler).

-export([init/3, handle/2, terminate/3]).

-define(JSON, {<<"content-type">>, <<"application/json">>}).

init(_Transport, Req, [MongoConnection]) ->
	{ok, Req, [MongoConnection]}.

handle(Req, [MongoConnection]) ->
	{ok, Req3} = case cowboy_req:method(Req) of
		{<<"GET">>,  Req2} -> get_quotations(Req2, MongoConnection);
		{<<"POST">>, Req2} -> add_quotation(Req2, MongoConnection);
		{_, Req2} -> cowboy_req:reply(405, [], <<"method not allowed">>, Req2)
	end,
	{ok, Req3, [MongoConnection]}.

terminate(_Reason, _Req, _State) ->
	ok.

get_quotations(Req, MongoConnection) ->
	Documents = quotelist_service:list_quotations(MongoConnection),
	Body      = jiffy:encode(Documents),
	cowboy_req:reply(200, [ ?JSON ], Body, Req).

add_quotation(Req, MongoConnection) ->
	{ok, ReqBody, Req2} = cowboy_req:body(Req),

	DecodedBody = jiffy:decode(ReqBody),

	Body   = get_json_value_by_key(DecodedBody, <<"body">>),
	Author = get_json_value_by_key(DecodedBody, <<"author">>),

	{ok, QuoteId} = quoteadd_service:add_quotation(Body, Author, MongoConnection),

	{ok, Req3} = cowboy_req:reply(201, [], quotelist_service:convert_uuid_to_hex(QuoteId), Req2),

	{ok, Req3}.

get_json_value_by_key(Body, Key) ->
	{Pairs} = Body,
	{Key, Value} = lists:keyfind(Key, 1, Pairs),
	Value.