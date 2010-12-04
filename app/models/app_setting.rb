# This is a generic key/value store model
class AppSetting
  include MongoMapper::Document
    
  #get or set a variable with the variable as the called method
  def self.method_missing(method, *args)
    method_name = method.to_s
    super(method, *args)
    
  rescue NoMethodError
    setting = self.first || self.new
    #set a value for a variable
    if method_name =~ /=$/
      var_name = method_name.gsub('=', '')
      value = args.first    
      setting[var_name] = value 
      setting.save 
    #retrieve a value
    else
      begin
        value = setting[method_name]  
        if value.blank?
          default_setting = DEFAULT_SETTINGS[method_name]
          if default_setting
            if default_setting.is_a?(Hash)
              Mash.new default_setting
            else
              default_setting
            end
          else
            nil
          end
        elsif value.is_a?(Hash)
          Mash.new(value)
        else
          value     
        end
      rescue
        default_setting = DEFAULT_SETTINGS[method_name]
        if default_setting
          if default_setting.is_a?(Hash)
            Mash.new default_setting
          else
            default_setting
          end
        else
          nil
        end
      end     
    end
  end
  
  private
    def read_from_defaults(method_name)
      default_setting = DEFAULT_SETTINGS[method_name]
      if default_setting
        if default_setting.is_a?(Hash)
          Mash.new default_setting
        else
          default_setting
        end
      else
        nil
      end
    end
  
end