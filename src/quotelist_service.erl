-module(quotelist_service).

-export([list_quotations/1]).
-export([convert_uuid_to_hex/1]).

list_quotations(MongoConnection) ->
	{ok, Documents} = query_for_quotations(MongoConnection),
	[ format_quotation(Doc) || Doc <- Documents ].

query_for_quotations(MongoConnection) ->
	mongo:do(safe, slave_ok, MongoConnection, quotable, fun() ->
		Cursor = mongo:find(quotations, { '$query', {}, '$orderby', {date, -1} }, {author, 1, body, 1, date, 1}),
		mongo_cursor:rest(Cursor)
	end).

format_quotation(Doc) ->
	FormattedFields = {
		'_id', convert_uuid_to_hex(bson:at('_id', Doc)),
		date, bson:unixtime_to_secs(bson:at(date, Doc))
	},
	FormattedDoc = bson:merge(FormattedFields, Doc),
	{ bson:fields(FormattedDoc) }.

convert_uuid_to_hex(BinaryListTuple) ->
	{BinaryList} = BinaryListTuple,
	list_to_binary(
		lists:flatten(
			[ string:to_lower(
				integer_to_list(X, 16)
			) || <<X>> <= BinaryList]
		)
	).

% flatten_timestamp(Timestamp) ->
% 	{MegaSeconds, Seconds, _} = Timestamp,
% 	MegaSeconds * 1000000 + Seconds.