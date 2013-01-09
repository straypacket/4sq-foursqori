require 'sinatra'
require 'open-uri'
require 'json'
require 'net/http'
require 'uri'
use Rack::Logger

access_token = 'JXQU5GQ5P3J1XCPUC1P1IIKMN1YFBFYKOPAT423FOA35DMKE'
user = {}

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
  	logger.info access_token
  	redirect '/success'
end

get '/privacy' do
	"Private means private :)"
end

post '/push' do
	checkinID = "50ed1b29e4b07aef2815178e"
	#checkinID = JSON.parse(params['checkin'])['id']
	uri = URI.parse("https://api.foursquare.com/v2/checkins/#{checkinID}/addpost?oauth_token=#{access_token}&v=20130108")

	logger.info params
	logger.info "https://api.foursquare.com/v2/checkins/#{checkinID}/addpost?oauth_token=#{access_token}&v=20130108"

	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Post.new(uri.request_uri)
	request.set_form_data({"text" => "Awesomeness", "url" => "http://badger.herokuapp.com/", "contentId" => "my_ID"})
	request["Content-Type"] = "application/json"
	response = http.request(request)
	return
end

get '/success' do
	"Congrats, you just linked your account to the amazing new app!"
end