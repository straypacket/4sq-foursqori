require 'sinatra'
require 'open-uri'
require 'json'
require 'net/https'
require 'uri'
use Rack::Logger

access_token = 'L53PUUE15WXV5T3ESPCCDGQ23KNONOTAH0JKVSATYN2Z3VUF'
user = {}

helpers do
  def logger
    request.logger
  end
end

get '/' do
	logger.info params
	"Nothing to see, move along"
end

get '/callback' do
	cli_id = "TIIWASIOG5LKB11BSVAMHTYBDVLUQDHTTJJHY4WTFBLU3EUQ"
	cli_sec = "3EW5M1APICBDW1HMHH4LUYH25KTDP4ZWOM3R4TPE1NFFIBRU"
	red_uri = "http://badger.herokuapp.com/callback"

	# Make request with params[:code]
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{red_uri}&code=#{params[:code]}"
  	rep = open(req).read
  	logger.info rep
  	rep_j = JSON.parse(rep)
  	access_token = rep_j['access_token']
  	logger.info access_token
  	redirect '/success'
end

get '/privacy' do
	"Private means private :)"
end

post '/push' do
	logger.info params

	checkinID = JSON.parse(params['checkin'])['id']
	args = "oauth_token=#{access_token}&v=20130108"
	url = "https://api.foursquare.com/v2/checkins/#{checkinID}/reply?#{args}"
	uri = URI.parse(url)
	msg = {"text" => "Advertisement", "url" => "http://badger.herokuapp.com/", "contentId" => "my_ID"}

	logger.info url

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	request = Net::HTTP::Post.new(uri.request_uri)
	request.set_form_data(msg)
	response = http.request(request)
	logger.info response
end

get '/success' do
	"Congrats, you just linked your account to the amazing Qori app!"
end