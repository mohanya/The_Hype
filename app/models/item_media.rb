class ItemMedia 
  include MongoMapper::Document
  # iPhone API
  include CustomJsonSerializer
  include IphoneApiMethods
  
  mount_uploader :image, ItemMediaUploader
  
  belongs_to :item
  
  key :item_id, String
  key :primary, Boolean
  
  timestamps!  

  def self.create_one(item, params_url, we_have_primary_image=false) 
    begin
      media = ItemMedia.new
      media.remote_image_url = params_url
      media.primary = true  unless we_have_primary_image
      if media.save
        item.medias << media
        we_have_primary_image = true
      end
    rescue
      puts "Failure Saving Primary/User Image: " + params_url + "\n\n"
    end
    return we_have_primary_image
  end

  def self.create_many(item_id, params_urls=[], we_have_primary_image=false) 
     params_urls.each do |key, url|
      unless url.blank?
        begin
          item = Item.find(item_id)
          media = ItemMedia.new
          media.remote_image_url = url
          media.primary = true  unless we_have_primary_image
          if media.save
            item.medias << media
            we_have_primary_image = true
          end
        rescue
          puts "Failure saving additional Image: " + url + "\n\n"
        end
      end
    end
    Item.find(item_id).update_attributes(:unfinished_images => false)
  end
  
  #####################
  #
  # iPhone API
  #
  ####################
  
  def caption 
    self.image_filename
  end
   
  def thumbnail_url 
    self.image_url(:thumb)
  end
  
  def small_image_url
    self.image_url
  end
  
  def large_image_url
    self.image_url
  end
   
end
