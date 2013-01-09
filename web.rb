require 'sinatra'
require 'open-uri'
require 'json'
use Rack::Logger

access_token = ''

helpers do
  def logger
    request.logger
  end
end

get '/' do
	"Nothing to see, move along"
end

get '/callback' do
	cli_id = "A1YEYC2T2MBCVEJU51HPNKZA4XLL41WQ24WMRCI0FAA5BCHS"
	cli_sec = "41T5JDOD3U5DGYIUFJVWCDF1CC1NI1A3WSH51EPJHGW5E04V"
	red_uri = "http://badger.herokuapp.com/callback"

	# Make request with params[:code]
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{red_uri}&code=#{params[:code]}"
  	rep = open(req).read
  	rep_j = JSON.parse(rep)
  	access_token = rep_j['access_token']
  	redirect '/success'
end

get '/privacy' do
	"Private means private :)"
end

post '/push' do
	logger.info params
	logger.info JSON.parse(params['checkin'])['id']
	#logger.info params
	#{}"Pushing ..."
end

get '/success' do
	"Congrats, you just linked your account to the amazing new app!"
end