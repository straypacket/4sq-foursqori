require 'sinatra'
require 'open-uri'
require 'json'
require 'net/https'
require 'uri'
require 'mongoid'

use Rack::Logger

user = {}
user[384595] = '3QMVI0GDT4PV5KTCM105JRDFV4ZDGZ0DS25E1R4CHXOKXE02'

## Configure logger
helpers do
  def logger
    request.logger
  end
end

## Connect to MongoDB
def get_connection
  return @db_connection if @db_connection
  db = URI.parse(ENV['MONGOHQ_URL'])
  db_name = db.path.gsub(/^\//, '')
  @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
  @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
  @db_connection
end

col = get_connection

get '/' do
	"Nothing to see, move along"
end

get '/callback' do
	cli_id = "TIIWASIOG5LKB11BSVAMHTYBDVLUQDHTTJJHY4WTFBLU3EUQ"
	cli_sec = "3EW5M1APICBDW1HMHH4LUYH25KTDP4ZWOM3R4TPE1NFFIBRU"
	redir_uri = "http://badger.herokuapp.com/callback"
	user_code = params['code']

	# Get access token
	req = "https://foursquare.com/oauth2/access_token?client_id=#{cli_id}&client_secret=#{cli_sec}&grant_type=authorization_code&redirect_uri=#{redir_uri}&code=#{user_code}"
  	rep = open(req).read
  	logger.info rep
  	rep_j = JSON.parse(rep)
  	access_token = rep_j['access_token']

  	# Get user info
	req = "https://api.foursquare.com/v2/users/self?oauth_token=#{access_token}&v=20130108"
  	rep = open(req).read
  	rep_j = JSON.parse(rep)
  	uid = rep_j['response']['user']['id']

  	user[uid] = access_token
  	rec = {:uid => uid, :token => access_token}
  	col.insert(rec)

  	logger.info user[uid]
  	logger.info col.find(:uid => uid)

  	redirect '/success'
end

get '/privacy' do
	"Private means private :)"
end

post '/push' do
	# Get user ID
	uid = JSON.parse(params['user'])['id']
	logger.info uid
	utoken = user[uid]
	logger.info utoken

	#Get checkin ID
	checkinID = JSON.parse(params['checkin'])['id']
	args = "oauth_token=#{utoken}&v=20130108"
	url = "https://api.foursquare.com/v2/checkins/#{checkinID}/reply?#{args}"
	uri = URI.parse(url)
	msg = {"text" => "Advertisement", "url" => "http://badger.herokuapp.com/", "contentId" => "my_ID"}

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	request = Net::HTTP::Post.new(uri.request_uri)
	request.set_form_data(msg)
	response = http.request(request)
	logger.info response.inspect
end

get '/success' do
	logger.info params
	"Congrats, you just linked your account to the amazing Qori app!"
end