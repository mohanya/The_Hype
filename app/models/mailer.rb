class Mailer < ActionMailer::Base
  
  def self.inherited_without_helper(subclass)
    @@subclasses ||= []
    @@subclasses << subclass
  end
  
  def self.subclasses
    @@subclasses
  end
  
  def self.available_templates
    @@subclasses.collect do |klass|
      klass.instance_methods(false)
    end.flatten
  end
  
  def setup_template(name, email, bcc_emails=[], template=true)
    site = SiteSetting.find(:first)
    from site.admin_email.to_s
    reply_to site.admin_email.to_s
    self.mailer_name = 'shared'
    self.template = 'email.html.erb'
    self.template_root = "#{RAILS_ROOT}/app/views"
    options = { 'site' => site }
    yield options if block_given?
    email_template = EmailTemplate.find_by_name(name)
    
    recipients "#{email}"
    
    sent_on Time.now

    if template
      subject "[#{site.name}] #{email_template.render_subject(options)}"
      body :content => email_template.render_body(options)
    elsif !template && block_given?
      subject "[#{site.name}] #{options['subject']}"
      body :content => options['content']
    end

    bcc(bcc_emails) if !bcc_emails.empty?
  end

  def info_for_admin(email)
    site = SiteSetting.find(:first)
    from site.admin_email.to_s
    reply_to site.admin_email.to_s
    recipients site.admin_email.to_s
    subject "#{email} removed account from The Hype "
    sent_on Time.now
    body "User #{email} removed account from The Hype on #{site.url} "
  end
end
