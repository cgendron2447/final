# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/cookies"                                                             #
require "sinatra/reloader" if development?  
require "geocoder"
require "sequel"                                                                      #
require "logger"                                                                      #
require "bcrypt"  
require "twilio-ruby"                                                                 #                                                  #
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
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

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
    @users_table = users_table
    @results = Geocoder.search(@location[:city_country])
    @lat_long = @results.first.coordinates
    @lat = @lat_long[0]
    @long = @lat_long[1]
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
                        user_id: session["user_id"],
                        date_visited: params["date_visited"],
                        food: params["food"],
                        hotel: params["hotel"],
                        comments: params["comments"])
    view "create_review"
end

get "/users/new" do
    view "users_new"
end


post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do  
    puts params
    email_address = params["email"]
    password = params["password"]

    @user = users_table.where(email: email_address).to_a[0] 

    if @user
        if BCrypt::Password.new(@user[:password]) == password
            session["user_id"] = @user[:id]
            @current_user = @user
            view "create_login"
        else 
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
  end


get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end