# == Schema Information
# Schema version: 20100413205506
#
# Table name: site_settings
#
#  id                  :integer(4)      not null, primary key
#  url                 :string(255)     
#  description         :string(255)     
#  name                :string(255)     
#  created_at          :datetime        
#  updated_at          :datetime        
#  beta_invites        :boolean(1)      
#  admin_email         :string(255)     
#  referrals           :boolean(1)      
#  blog                :boolean(1)      
#  newsletter          :boolean(1)      
#  user_avatar_upload  :boolean(1)      
#  allow_blog          :boolean(1)      
#  cm_api_key          :string(255)     
#  cm_subscribers_list :string(255)     
#


class SiteSetting < ActiveRecord::Base
  liquid_methods :name, :url
  
  def self.layouts
    dir = Dir.new("app/views/layouts")
    layouts = []
    dir.each {|file| layouts << file unless file == "." || file == ".."}
    layouts.collect {|file| file unless file =~ /^_/}.compact
  end
  
end
