class TrustedBrand < ActiveRecord::Base
  belongs_to :profile
  default_scope :order => :pos
  before_save :strip_name
  validates_presence_of :pos
  
private 
  def strip_name
    self.name.strip!
  end
end
