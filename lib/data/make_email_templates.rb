def create_email_template_unless_exists(name, subject, &blk)
  unless EmailTemplate.count(:conditions => { :name => name }) == 1
    e = EmailTemplate.new(:name => name, :subject => subject, :body => blk.call)
    e.name = name
    e.save
  end
end

create_email_template_unless_exists('signup', 'Please activate your new account') do
<<-END
Your account has been created.

  Username: {{user.login}}

Visit this url to activate your account:

  {{site.url}}/users/activate/{{user.activation_code}}
END
end

create_email_template_unless_exists('activation', 'Your account has been activated') do
<<-END
{{user.login}}, your account has been activated.

  {{site.url}}/
END
end

create_email_template_unless_exists('forgot_password', 'Password change request') do
<<-END
{{user.login}},

You have requested to have your password reset. Click the link below to change your password.

{{site.url}}/passwords/{{user.password_reset_code}}/edit
END
end

create_email_template_unless_exists('reset_password', 'Your password has been reset') do
<<-END
{{user.login}}

Your password has been reset.

{{site.url}}/
END
end

create_email_template_unless_exists('invitation', "You have been invited to {{site.name}}") do
<<-END
You've been invited to try out a new website.

Visit this url below to signup for an account, and make sure you use this email address:

{{site.url}}/signup/{{string_id}}
END
end

create_email_template_unless_exists('referral', "Your friend wants to share this website with you") do
<<-END
Hello. Your friend wanted us to send this email to you to let you know about {{site.name}}. We gave them an option to include a personal note below.

Personal note
====================================

{{note}}

===

Please take a moment to visit {{site.name}}'s website {{site.url}}.

END
end

create_email_template_unless_exists('confirmation', "You have sent the website to your friends") do
<<-END
Hello. We sent the email to your friends about {{site.name}}.

We just wanted to take a moment to say: Thanks for sharing our website!
END
end

create_email_template_unless_exists('admin_confirmation', "Someone sent a friend referral") do
<<-END
{{referrer.email}} sent a referral about {{site.name}} to:

{% for referral in referrals %}
  {{referral.email}}
{% endfor %}
END
end

create_email_template_unless_exists('follower_notice', "You've got a new follower") do
<<-END
Hi there!

User {{follower.login}} has just started following you.

Your actions will be seen from now on on their profile.

All the best,

The Hype Team 

END
end

create_email_template_unless_exists('email_notice', "You've got a new message") do
<<-END
Hi there!

User {{sender.login}} has just sent a message to you.

In order to read it, please visit your inbox: http://thehype.com/inbox/messages

All the best,

The Hype Team 

END
end

create_email_template_unless_exists('comment_notice', "Somebody has commented an item commented by you") do
<<-END
Hi there!

User {{commentator.login}} has just commented item {{item_name}}

Visit the {{site.url}} to see if it is interesting!

All the best,

The Hype Team 

END
end

create_email_template_unless_exists('comment_notice_to_item_owner', "Somebody has commented your item") do
<<-END
Hi there!

User {{commentator.login}} has just commented item {{item_name}}

Visit the {{site.url}} to see if it is interesting!

All the best,

The Hype Team 

END
end

create_email_template_unless_exists('invitation_to_gmail_friend', "{{user.login}} wants to share this website with you") do
<<-END
{{user.login}} wants to share this website with you.

Please take a moment to visit {{site.name}}'s website {{site.url}}.

END
end

create_email_template_unless_exists('request_to_follow', "You've got a new follow request") do
<<-END
Hi there!

User {{sender.login}} has just sent a follow request to you.

In order to accept/reject it, please visit your inbox: {{site.url}}/inbox/messages

All the best,

The Hype Team 

END
end

