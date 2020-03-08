# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :locations do
  primary_key :id
  String :city_country
  String :description, text: true
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :location_id
  foreign_key :user_id
  String :date_visited
  String :food
  String :hotel
  String :comments, text: true
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
locations_table = DB.from(:locations)

locations_table.insert(city_country: "Dubrovnik, Croatia", 
                    description: "Historically Ragusa, Dubrovnik is a city on the Adriatic Sea in southern Croatia. It is one of the most prominent tourist destinations in the Mediterranean Sea, a seaport and the centre of Dubrovnik-Neretva County. Its total population is 42,615 (census 2011). In 1979, the city of Dubrovnik joined the UNESCO list of World Heritage sites.
")

locations_table.insert(city_country: "Zermatt, Switzerland", 
                    description: "In southern Switzerland’s Valais canton, is a mountain resort renowned for skiing, climbing and hiking. The town, at an elevation of around 1,600m, lies below the iconic, pyramid-shaped Matterhorn peak. Its main street, Bahnhofstrasse is lined with boutique shops, hotels and restaurants, and also has a lively après-ski scene. There are public outdoor rinks for ice-skating and curling.")
                  
locations_table.insert(city_country: "Munich, Germany", 
                    description: "Munich, Bavaria’s capital, is home to centuries-old buildings and numerous museums. The city is known for its annual Oktoberfest celebration and its beer halls, including the famed Hofbräuhaus, founded in 1589. In the Altstadt (Old Town), central Marienplatz square contains landmarks such as Neo-Gothic Neues Rathaus (town hall), with a popular glockenspiel show that chimes and reenacts stories from the 16th century.")

