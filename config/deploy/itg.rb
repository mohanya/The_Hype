role :web, '174.129.217.125'
role :app, '174.129.217.125'
role :db, '174.129.217.125', :primary => true
set :environment_database, Proc.new { production_database }
set :dbuser,        'app'
set :dbpass,        '7TQcg4JwuK'
set :user,          'app'
set :password,      '7TQcg4JwuK'
set :runner,        'app'
set :rails_env,     'production'

set :rails_env, "production"