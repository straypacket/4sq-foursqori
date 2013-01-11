require 'sinatra'
require 'open-uri'
require 'json'
require 'net/https'
require 'uri'
require 'mongoid'

set :static, true
set :public_folder, 'public'

use Rack::Logger

## Configure logger
helpers do
  def logger
    request.logger
  end
end

## Connect to MongoDB
#Mongoid.load!('./mongoid.yml', :development)
Mongoid.load!('./mongoid.yml')

## Define Mongoid document
class Users
  include Mongoid::Document
  field :uid, :type => String
  field :token, :type => String
end 

get '/' do
	link = "http://foursquare.com/oauth2/authenticate?client_id=TIIWASIOG5LKB11BSVAMHTYBDVLUQDHTTJJHY4WTFBLU3EUQ&response_type=code&redirect_uri=http://foursqori.herokuapp.com/callback"
	button = "https://playfoursquare.s3.amazonaws.com/press/logo/connect-white.png"
	shot = "http://foursqori.herokuapp.com/shot.png"
	"<h1>Welcome to Qori for Foursquare, FoursQori</h1><br>You'll be receiving private awesome deals after each check-in, just like depicted below:<br><img src=#{shot}><br>Please press the button below to access awesome deals<br><a href=#{link}><img src=#{button}></a>"
end

get '/callback' do
	cli_id = "TIIWASIOG5LKB11BSVAMHTYBDVLUQDHTTJJHY4WTFBLU3EUQ"
	cli_sec = "3EW5M1APICBDW1HMHH4LUYH25KTDP4ZWOM3R4TPE1NFFIBRU"
	redir_uri = "http://foursqori.herokuapp.com/callback"
	user_code = params['code']

	# Get access token
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{redir_uri}&code=#{user_code}"
  	rep = open(req).read
  	rep_j = JSON.parse(rep)
  	q = rep_j['access_token']

  	if q
  		access_token = q
  	else
		logger.info "No access token found!"
		redirect '/error'
  	end

  	# Get user ID
	req = "https://api.foursquare.com/v2/users/self?oauth_token=#{access_token}&v=20130108"
  	rep = open(req).read
  	rep_j = JSON.parse(rep)
  	q = rep_j['response']['user']['id']

  	if q
  		uid = q
  	else
		logger.info "No user ID found!"
		redirect '/error'
  	end

  	# Store user token
  	Users.where(:uid => uid).delete
  	Users.create(:uid => uid, :token => access_token)

  	#Debug
  	#logger.info Users.where(uid: uid).first.token

  	# Landing page
  	redirect '/success'
end

get '/privacy' do
	"Private means private :)"
end

post '/push' do
	# Get user ID
	q = JSON.parse(params['user'])['id']
	if q
		uid = JSON.parse(params['user'])['id']
	else
		logger.info "No user ID found!"
		redirect '/error'
	end

	# Get user token
	q = Users.where(uid: uid).first
	if q
		utoken = q.token
	else
		logger.info "No user token found!"
		redirect '/error'
	end

	#Get checkin ID
	q = JSON.parse(params['checkin'])['id']
	if q
		checkinID = q
	else
		logger.info "No checkin ID found!"
		redirect '/error'
	end

	#Get geofence
	location = JSON.parse(params['checkin'])['venue']['location']
	req = "http://geo.skillupjapan.net/squares/get_random_geo_object?long=#{location['lng']}&lat=#{location['lat']}"
  	rep = open(req).read
  	rep_j = JSON.parse(rep)

  	msg = {}
  	if rep_j['error']
		logger.info "No checkin ID found!"
		redirect '/error'
		msg = {"text" => "Default advertisement", "url" => "http://foursqori.herokuapp.com/", "contentId" => "my_ID"}
	else
		if rep_j['message']
			msg = {"text" => "rep_j['geo_object']['message']", "url" => "http://geo.skillupjapan.net/#{rep_j['geo_object']['uri']}", "contentId" => "my_ID"}
		else
			msg = {"text" => "Real advertisement for #{rep_j['geo_object']['filename']}", "url" => "http://geo.skillupjapan.net/#{rep_j['geo_object']['uri']}", "contentId" => "my_ID"}
		end
	end

	# Build message
	args = "oauth_token=#{utoken}&v=20130108"
	url = "https://api.foursquare.com/v2/checkins/#{checkinID}/reply?#{args}"
	uri = URI.parse(url)

	# Send message
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	request = Net::HTTP::Post.new(uri.request_uri)
	request.set_form_data(msg)
	response = http.request(request)

	# Debug
	#logger.info response.inspect
end

get '/success' do
	"Congrats, you just linked your account to the amazing FoursQori app!"
end

get '/error' do
	"Sorry, there was an error with your request"
end
