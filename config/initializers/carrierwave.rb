s3_config = YAML::load(File.read(RAILS_ROOT + "/config/amazon_s3.yml"))

s3 = s3_config[Rails.env]

CarrierWave.configure do |config|
  config.s3_access_key_id = s3['access_key_id']
  config.s3_secret_access_key = s3['secret_access_key']
  config.s3_bucket = "#{Rails.env}.thehype.com"
end