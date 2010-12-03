namespace :the_hype do
  desc "Update Product API data"
  task :update_product_api_data => :environment do
    
    Item.all.each do |item|      
      puts "Updating #{item.id}"
      unless item.source_id.blank?
        item.item_details = []
        if item._type == "Item"
          item._type = "Product" 
          item.save
          item.reload
        end
        item.get_data_from_api if item.type == Product
        item.save 
      end
    end
        
  end
  
  desc "Update item_id to product_id on Reviews"
  task :update_reviews_to_product_id => :environment do
    
    Review.all.each do |review|  
      if review.item_id
        review["product_id"] = review.item_id
        review.save
      end
    end
        
  end
  
  desc "Update primary media images"
  task :update_primary_media => :environment do
    Item.all.each do |item|
       begin
         if item.image_url and !item.image_url.blank?
            media = item.medias.select {|m| m.primary == true}.first || item.medias.first || item.medias.build
            i_url = item.image_url.split(":").last
            i_url = (i_url.starts_with?("//") ? 'http:' : 'http://') + i_url
            media.remote_image_url = CGI.unescape(i_url)
            media.primary = true
            media.save
            puts item.id + " updated"
         end
      rescue => ex
        puts "#{ex.message}"
      end
    end
  end
  
end