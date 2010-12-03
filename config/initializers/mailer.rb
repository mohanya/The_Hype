ActionMailer::Base.raise_delivery_errors = true  
ActionMailer::Base.default_charset = "utf-8"

ActionMailer::Base.smtp_settings = {
:address => 'smtp.gmail.com',
:port => 587,
:domain => 'thehypenetworks.com',
:authentication => :plain,
:user_name => 'invite@thehypenetworks.com',
:password => 'getready4thehype'
}