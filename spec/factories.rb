#require 'factory_girl'

Factory.define :site_setting do |f|
  f.beta_invites false
  f.name "The Hype"
  f.url "http://localhost:3000"
  f.description "The Hype Website"
  f.admin_email "admin@localhost:3000"
end

Factory.sequence :login do |n|
  "bob#{n}" 
end

Factory.sequence :email do |n|
  "person#{n}@example.com" 
end

Factory.sequence :name do |n|
  "name#{n}-#{n}-#{(Time.now + n.seconds).to_s}" 
end

Factory.define :education_level do |f|
  f.sequence(:name) { |n| "College Year #{n+1}" }
end

Factory.define :interest do |f|
  f.name "Being a dad"
  f.sequence(:pos) { |n| n+1 }
  f.association(:profile)
end

Factory.define :trusted_brand do |f|
  f.name "Texas Instruments"
  f.sequence(:pos) { |n| n+1 }
  f.association(:profile)
end

Factory.define :profile do |f|
  f.sequence(:email) { |n| "person#{n}@example.com" }
  f.sequence(:first_name) { |n| "Joe#{n}" }
  f.sequence(:last_name) { |n| "Shmoe#{n}" }
  f.gender 'Male'
  f.birth_date 25.years.ago
end


Factory.define :user do |u|
  u.sequence(:login) { |n| "bob#{n}" }
  u.password "tester1"
  u.password_confirmation "tester1"
  u.sequence(:email) { |n| "person#{n}@example.com" }
  u.time_zone "Pacific Time (US & Canada)"
  u.profile_attributes Factory.attributes_for(:profile, :assigned_to_user => true).reject {|k,v| k == :email}
end

Factory.define :admin, :class => :user do |u|
  u.sequence(:login) { |n| "admin#{n}" }
  u.password "admin1"
  u.password_confirmation "admin1"
  u.sequence(:email) { |n| "admin#{n}@example.com" }
  u.profile_attributes Factory.attributes_for(:profile, :assigned_to_user => true).reject {|k,v| k == :email}
  u.admin true
end

Factory.define :invite do |u|
  u.sequence(:email) { |n| "person#{n}@example.com" }
  u.association :inviter, :factory => :user
end

Factory.define :email_template do |e|
  e.sequence(:name)  { |n| "name#{n}-#{n}-#{(Time.now + n.seconds).to_s}" }
  e.subject 'some important news'
  e.body 'booyakasha'
end

Factory.define :post do |p|
  p.title "Imaginative Title Goes Here"
  p.body "This is the blog post body"
  p.state "draft"
  p.association :author, :factory => :user
end

Factory.define :subscription do |s|
  s.signup_ip_address "192.1.1.1"
  s.association :profile
end

Factory.define :delayed_job, :class => Delayed::Job do |dj|
  dj.handler "AR::User"
end


Factory.define :friendship do |f|
  f.association :user, :factory => :user
  f.association :friend, :factory => :user
end

Factory.define :review do |r|
end

Factory.define :comment do |c|
  c.association :user, :factory => :user
  c.association :item, :factory => :item
  c.content 'YEH! first.'
end

Factory.define :item do |f|
  f.sequence(:name) { |n| "Item#{n}" }
  f.source_name { 'www.source.com' }
  f.short_description { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' }
end

Factory.define :item_category do |f|
end

Factory.define :item_comment do |c|
  c.comment_text 'this is my comment text'
end

Factory.define :peer_review do |p|
  p.association :user, :factory => :user
  p.association :review, :factory => :review
  p.helpful_review false
end

Factory.define :message do |f|
  f.sender_id 1
  f.receiver_id 1
  f.subject "Helpful hype"
  f.body "Wow your hype was really helpful"
  f.read false
end

Factory.define :label do |f|
end

Factory.define :label_stat do |f|
end

Factory.define :item_media do |f|
  f.sequence(:image_filename) { |n| "Photo_#{n}" }
end

Factory.define :item_detail do |f|
end

Factory.define :activity do |f|
end
