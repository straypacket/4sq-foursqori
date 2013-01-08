require 'sinatra'

get '/' do
  "Nothing to see, move along"
end

get '/redirect' do
	"Redirecting!"
end

get '/callback' do
	"Callback ..."
end