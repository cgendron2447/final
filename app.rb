# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

locations_table = DB.from(:locations)
reviews_table = DB.from(:reviews)

get "/" do
    puts "params: #{params}"

    pp locations_table.all.to_a
    @locations = locations_table.all.to_a
    view "all_locations"
end

get "/locations/:id" do
    puts "params: #{params}"

    @location = locations_table.where(id: params[:id]).to_a[0]
    pp @location
    @reviews = reviews_table.where(location_id: @location[:id]).to_a
    @review_count = reviews_table.where(location_id: @location[:id]).count
    view "location_review"
end

get "/locations/:id/reviews/new" do
    puts "params: #{params}"

    @location = locations_table.where(id: params[:id]).to_a[0]
    pp @location
    view "new_review"
end

get "/locations/:id/reviews/create" do
    puts params 
    @location = locations_table.where(id: params[:id]).to_a[0]

    reviews_table.insert(location_id: params["id"],
                        name: params["name"],
                        email: params["email"],
                        date_visited: params["date_visited"],
                        food: params["food"],
                        hotel: params["hotel"],
                        comments: params["comments"])
    view "create_review"
end