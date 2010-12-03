# == Schema Information
# Schema version: 20090715085613
#
# Table name: email_templates
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     
#  body       :text            
#  created_at :datetime        
#  updated_at :datetime        
#  subject    :string(255)     
#

class EmailTemplate < ActiveRecord::Base
  attr_protected :name
  
  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :body
  validates_uniqueness_of :name

  def render_body(options = {})
    render(self.body, options)
  end
  
  def render_subject(options = {})
    render(self.subject, options)
  end
  
  private
  
    def render(text, options)
      Liquid::Template.parse(text).render(options)
    end
  
end
