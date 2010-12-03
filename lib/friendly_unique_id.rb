module FriendlyUniqueId
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def has_friendly_unique_id(*attrs)
      class << self; attr_accessor :friendly_field_name end
      @friendly_field_name = attrs[0]
      
      class_eval <<-EOV
        include FriendlyUniqueId::InstanceMethods        
        before_create :generate_unique_id 
      EOV
           
    end        
  end

  module InstanceMethods
    require 'stringex'  
    
    def generate_unique_id
         
      unique_id = self[self.class.friendly_field_name.to_sym].to_url

      #Create case-insensitve regular expression
      regexp = Regexp.new(unique_id, true)
      
      # If you have a class that is inherited, use the superclass
      # We use == instead of is_a?() here because inherited classes will not == Object
      if self.class.superclass == Object
        obj = self.class.find_all_by_id(regexp)
      else
        obj = self.class.superclass.find_all_by_id(regexp)
      end
      
      unless obj.to_a.empty?
        max_ordinal = obj.map {|o| o.id_ordinal}.max
        unique_id += "-" + (max_ordinal + 1).to_s
      end
      self.id = unique_id
    end 
    
    def id_ordinal
      self.id.gsub(self[self.class.friendly_field_name.to_sym].to_url,"").gsub("-", "").to_i
    end
  end
end

# class MongoMapper::Document
#   include FriendlyUniqueId
# end