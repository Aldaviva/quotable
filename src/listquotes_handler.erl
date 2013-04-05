-module(listquotes_handler).

-export([init/3, handle/2, terminate/3]).

-define(JSON, {<<"content-type">>, <<"application/json">>}).

init(_Transport, Req, State) ->
	{ok, Req, State}.

handle(Req, [MongoConnection, StreamClientRegistry]) ->
	{ok, Req3} = case cowboy_req:method(Req) of
		{<<"GET">>,  Req2} -> get_quotations(Req2, MongoConnection);
		{<<"POST">>, Req2} -> add_quotation(Req2, MongoConnection, StreamClientRegistry);
		{_, Req2}          -> cowboy_req:reply(405, [], <<"method not allowed">>, Req2)
	end,
	{ok, Req3, [MongoConnection]}.

terminate(_Reason, _Req, _State) ->
	ok.

get_quotations(Req, MongoConnection) ->
	Documents = quotelist_service:list_quotations(MongoConnection),
	Body      = jiffy:encode(Documents),
	cowboy_req:reply(200, [ ?JSON ], Body, Req).

add_quotation(Req, MongoConnection, StreamClientRegistry) ->
	{ok, ReqBody, Req2} = cowboy_req:body(Req),

	DecodedBody = jiffy:decode(ReqBody),

	Body   = get_json_value_by_key(DecodedBody, <<"body">>),
	Author = get_json_value_by_key(DecodedBody, <<"author">>),

	ValidationMessage = if
		Body   =:= missing_key -> <<"Missing 'body' field.">>;
		Author =:= missing_key -> <<"Missing 'author' field.">>;
		true                   -> none
	end,

	{ok, Req3} = if
		ValidationMessage =:= none ->
			{ok, QuoteId} = quoteadd_service:add_quotation(Body, Author, MongoConnection),
			QuoteIdString = quotelist_service:convert_uuid_to_hex(QuoteId),
			StreamClientRegistry ! {self(), list},
			receive 
				{list, Clients} -> lists:foreach(fun(Client) ->
						Client ! {message, QuoteIdString}
					end, Clients)
			end,
			cowboy_req:reply(201,
				[{<<"content-type">>, <<"text/plain">>}], 
				lists:flatten([<<"{\"_id\":\"">>, QuoteIdString, <<"\"}">>]),
				Req2);
		true -> 
			cowboy_req:reply(400, [], ValidationMessage, Req2)
	end,

	{ok, Req3}.

get_json_value_by_key(Body, Key) ->
	{Pairs} = Body,
	case lists:keyfind(Key, 1, Pairs) of
		{Key, Value} -> Value;
		false -> missing_key
	end.