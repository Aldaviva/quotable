-module(quoteadd_service).

-export([add_quotation/3]).

add_quotation(Body, Author, MongoConnection) ->
	Document = create_document(Body, Author),
	{ok, Id} = mongo:do(safe, slave_ok, MongoConnection, quotable, fun() ->
		mongo:insert(quotations, Document)
	end),
	{ok, Id}.

create_document(Body, Author) ->
	{
		body, Body,
		author, Author,
		date, now()
	}.