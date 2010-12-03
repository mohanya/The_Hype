# encoding: utf-8
class ItemMediaUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::MiniMagick
  
  # Include RMagick or ImageScience support
  #     include CarrierWave::RMagick
  #     include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader
  # storage :cloud_files
  unless Rails.env.test? or Rails.env.cucumber?
    storage :s3
  end

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  def cache_dir
    "#{RAILS_ROOT}/tmp/uploads"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url
    "/images/app/icon_hype_large.png"
  end

  # Process files as they are uploaded.
  #     process :scale => [200, 300]
  #
  #     def scale(width, height)
  #       # do something
  #     end

  # Create different versions of your uploaded files
  version :large do
    process :resize_to_limit => [240, 240]
  end
  
  version :thumb do
    process :resize_to_limit => [160, 160]
  end
  
  version :tiny_thumb do
    process :resize_to_limit => [70, 70]
  end   

  # Add a white list of extensions which are allowed to be uploaded,
  # for images you might use something like this:
  #     def extension_white_list
  #       %w(jpg jpeg gif png)
  #     end

  # Override the filename of the uploaded files
  #     def filename
  #       "something.jpg" if original_filename
  #     end

end
