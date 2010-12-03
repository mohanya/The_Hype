namespace :items do
  desc 'add integer_id to every model which iPhone API uses'
  # IMPORTANT - comment all unnecessary and complex after save/update callbacks to minimize the time before run

  task :item_add_int_id => :environment do
    i = 1
    Item.all.each do |item|
      item.integer_id = i
      item.save
      i += 1
    end
  end
  
  task :review_add_int_id => :environment do
    i = 1
    Review.all.each do |item|
      item.integer_id = i
      item.save
      i += 1
    end
  end
  
  task :comment_add_int_id => :environment do
    i = 1
    Comment.all.each do |item|
      item.integer_id = i
      item.save
      i += 1
    end
  end

end