.PHONY: all deps run start css

all: css
	@rebar compile

deps:
	@rebar get-deps compile

css:
	@mkdir -p public/media/styles
	@lessc styles/all.less > public/media/styles/all.css

run:
	@erl -pa ebin deps/*/ebin -s quotable

start: run