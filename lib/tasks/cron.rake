task :cron => :environment do  
  puts "Begin fetching trends"
  puts "START: " + Time.now.to_s
  Item.all.each do |item|
    #puts "Fetching Twitter trends for " + item.name.to_s + " (" + item.id.to_s + ") at " + Time.now.to_s
    item.fetch_all_trends('twitter')
    #puts "Fetching Facebook trends for " + item.name.to_s + " (" + item.id.to_s + ") at " + Time.now.to_s
    item.fetch_all_trends('facebook')
  end
end
