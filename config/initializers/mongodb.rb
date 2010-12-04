if ENV['MONGOHQ_URL']
  MongoMapper.config = {RAILS_ENV => {'uri' => ENV['MONGOHQ_URL']}}
  MongoMapper.connect(RAILS_ENV)
else
  config = YAML::load(File.read(Rails.root.join('config/mongodb.yml'))) 
  MongoMapper.setup(config, Rails.env) 
end



# db_config = YAML::load(File.read(RAILS_ROOT + "/config/mongodb.yml"))
# # 
# mongo = db_config[Rails.env]
# MongoMapper.connection = Mongo::Connection.new(mongo['host'])
# MongoMapper.database = mongo['database']
# MongoMapper.database.authenticate(mongo['username'], mongo['password'])
# 
# # Handle the creation of new processes by Phusion Passenger
# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     if forked
#       # We're in smart spawning mode.
# 
#       # Reset the connection to MongoDB
#       #MongoMapper.database.close
#       # load File.join(RAILS_ROOT, 'config/initializers/mongo.rb')
#       MongoMapper.connection = Mongo::Connection.new(mongo['host']) if Rails.env.production?
#       MongoMapper.database = mongo['database']
#       MongoMapper.database.authenticate(mongo['username'], mongo['password'])
#     else
#       # We're in conservative spawning mode. We don't need to do anything.
#     end
#   end
# end