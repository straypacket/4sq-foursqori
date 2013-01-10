require 'sinatra'
require 'open-uri'
require 'json'
require 'net/https'
require 'uri'
use Rack::Logger

access_token = '1HRDYGIIZBCVETCM1HK0FUEEIPN5RMKBHCEVSH1LNFWYSW30'
code = 'DBSFFLLX5QPYWEQMKSTK1BEFYIULPZEXUTUNUGCPX13CYC1U'
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

get '/test' do
	logger.info '/test '+params
	"Testing ..."
end

get '/callback' do
	cli_id = "TIIWASIOG5LKB11BSVAMHTYBDVLUQDHTTJJHY4WTFBLU3EUQ"
	cli_sec = "3EW5M1APICBDW1HMHH4LUYH25KTDP4ZWOM3R4TPE1NFFIBRU"
	redir_uri = "http://badger.herokuapp.com/callback"
	logger.info '/callback '+params
	user_code = params['code']
	logger.info '/callback '+user_code


	# Make request with params[:code]
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{redir_uri}&code=#{params[:code]}"
  	#req = "https://foursquare.com/oauth2/authenticate?client_id=#{cli_id}&response_type=token&redirect_uri=#{redir_uri}"
  	rep = open(req).read
  	logger.info '/callback '+rep
  	rep_j = JSON.parse(rep)
  	access_token = rep_j['access_token']
  	user[user_code] = access_token
  	logger.info '/callback '+access_token
  	#redirect '/success'
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

	logger.info '/push '+url

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	request = Net::HTTP::Post.new(uri.request_uri)
	request.set_form_data(msg)
	response = http.request(request)
	logger.info '/push '+response
end

get '/success' do
	logger.info '/success '+params
	"Congrats, you just linked your account to the amazing Qori app!"
end