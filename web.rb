require 'sinatra'
require 'open-uri'

get '/' do
	"Nothing to see, move along"
end

get '/redirect' do
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
	cli_id = "A1YEYC2T2MBCVEJU51HPNKZA4XLL41WQ24WMRCI0FAA5BCHS"
	cli_sec = "41T5JDOD3U5DGYIUFJVWCDF1CC1NI1A3WSH51EPJHGW5E04V"
	red_uri = "http://badger.herokuapp.com/test"

	# Make request with params[:code]
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{red_uri}&code=#{params[:code]}"
  	open('http://maps.google.com/maps/api/staticmap').read
end