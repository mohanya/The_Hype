require 'machinist/active_record'
require 'machinist/mongo_mapper'
require 'forgery'

# Shams
# We use forgery to make up some test data

Sham.login { InternetForgery.user_name }
Sham.name  { NameForgery.company_name }
Sham.last_name  { NameForgery.last_name }
Sham.text { LoremIpsumForgery.sentence }

Profile.blueprint do
  first_name NameForgery.first_name
  last_name NameForgery.last_name
  email InternetForgery.email_address
  gender {'Male'}
  birth_date {25.years.ago}
end

User.blueprint do
  profile_attributes {
    Profile.plan(:assigned_to_user => true).reject {|k,v| k == :email}
  }
  login InternetForgery.user_name
  password {'awesome'}
  password_confirmation {'awesome'}
  email InternetForgery.email_address
  time_zone { "Pacific Time (US & Canada)" }
end

Item.blueprint do
  name  { Sham.name }
  source_id { "superawesome_pc_123456" }
  category_id { ItemCategory.make.id }
end

ItemComment.blueprint do
  user_id { User.make.id }
  item_id { Item.make.id }
  comment_text LoremIpsumForgery.sentence
end

ItemFavorite.blueprint do
  user_id { User.make.id }
  item_id { Item.make.id }
  favorite { true }
end

ItemCategory.blueprint do
  name { "Product" }
  tag_name { "product" }
  api_source AppSetting.api_sources[0]
end

Review.blueprint do
  user_id { User.make.id }
  item_id { Item.make.id }
  criteria_1  { 1 }
  criteria_2 { 1 }
  criteria_3 { 1 }
  pros { ["size", "speed"] }
  cons { ["price", "processor"] }
end

ItemFavorite.blueprint do
  user_id { User.make.id }
  item_id { Item.make.id }
end

UserTop.blueprint do
  user_id { User.make.id }
  item_id { Item.make.id }
end
