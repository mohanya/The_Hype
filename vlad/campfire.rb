namespace :vlad do

  task :campfire do
    require 'tinder'
    campfire = Tinder::Campfire.new 'handcrafted', :ssl => false
    campfire.login 'deploy@gethandcrafted.com', 'get2Krafty'
    ROOM = campfire.find_room_by_name campfire_room    
  end

  task :pre_announce => [:campfire] do
    ROOM.paste "#{ENV['USER']} is preparing to deploy #{application}"
  end

  task :post_announce do
    ROOM.paste "#{ENV['USER']} finished deploying #{application}"
  end
  
  task :update => [:pre_announce]
  
  task :start_app => [:post_announce]

end