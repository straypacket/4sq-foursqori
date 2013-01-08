require 'sinatra'

get '/' do
	"Nothing to see, move along"
end

get '/redirect' do
	puts params
	"Redirecting!"
end

get '/callback' do
	"Callback ..."
end

get '/privacy' do
	"Private means private :)"
end

get '/push' do
	"Pushing ..."
end

get '/test' do
	puts params
end