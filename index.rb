require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'mongo'
require 'json'
require 'less'
require 'eventmachine'

include Mongo
register Sinatra::Async

mongo_client = MongoClient.new("localhost", 27017, :j => true)
db           = mongo_client.db("quotable")
collection   = db.collection("quotations")

postChannel = EventMachine::Channel.new

configure do
	set :bind, "0.0.0.0"
	set :server, :rainbows
	set :static_cache_control, [:public, max_age: 60 * 60 * 24 * 365]
end

before do
	response.headers["Connection"] = "close"
end

get '/' do
	quotations = collection.find({}, { :sort => [[:date, Mongo::DESCENDING]], :limit => 100 }).to_a
	erb :list, :locals => { :quotations => quotations }
end

post '/' do
	author = request["author"]
	body   = request["body"]
	if(!author.strip.empty? && !body.strip.empty?) then
		collection.insert({
			:body   => body,
			:author => author,
			:date   => Time.now
		})
		puts "inserted new quotation from "+author
	end

	postChannel.push("new post")
	puts "publish"

	redirect to('/')
end

get '/stylesheet.css' do
	less :stylesheet
end

aget '/subscribe' do
	sid = postChannel.subscribe{ |msg|
		body(msg)
		postChannel.unsubscribe(sid)
	}
	puts "subscribe"
end

def randomPaperName
	@suffixes = %w[ post star gossip news times herald record advertiser dispatch gazette journal bugle review pioneer citizen standard bulletin clipper press sentinel extra voice tribune reporter report independent express beacon echo advocate statesman observer ledger clarion chronicle globe telegraph messenger sun examiner mail register enterprise ]
	@prefixes = %w[ new old daily weekly hometown local county national state tri-county valley district northern southern eastern western ].concat(@suffixes)
	@name = "The "+@prefixes.sample+" "+@suffixes.sample(Random::rand(2)+1).join('-')
	@name.gsub(/(?:[^a-zA-Z])([a-z])/) { |char| char.upcase }
end
