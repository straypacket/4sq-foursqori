require 'sinatra'
require 'open-uri'
require 'json'

access_token = ''

get '/' do
	"Nothing to see, move along"
end

get '/redirect' do
	"Redirecting!"
end

get '/callback' do
	require 'keys.rb'

	# Make request with params[:code]
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{red_uri}&code=#{params[:code]}"
  	rep = open(req).read
  	rep_j = JSON.parse(rep)
  	access_token = rep_j['access_token']
  	#redirect '/success'
end

get '/privacy' do
	"Private means private :)"
end

get '/push' do
	"Pushing ..."
end

get '/success' do
	"Congrats, you just linked your account to the amazing new app!"
end