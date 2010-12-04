module CustomJsonSerializer
  # iPhone API
  def as_json options={}
    options ||= {}
    unless options[:only]
      methods = [options.delete(:methods)].flatten.compact
      #methods << :id
      options[:methods] = methods.uniq
    end

    except = [options.delete(:except)].flatten.compact
    except << :_id
    options[:except] = except

    # Direct rip from Rails 3 ActiveModel Serialization (#serializable_hash)
    hash = begin
      options[:only]   = Array.wrap(options[:only]).map { |n| n.to_s }
      options[:except] = Array.wrap(options[:except]).map { |n| n.to_s }

      attribute_names = attributes.keys.sort
      if options[:only].any?
        attribute_names &= options[:only]
      elsif options[:except].any?
        attribute_names -= options[:except]
      end

      method_names = Array.wrap(options[:methods]).inject([]) do |methods, name|
        methods << name if respond_to?(name.to_s)
        methods
      end
      
      (attribute_names + method_names).inject({}) { |hash, name|
        hash[name] = send(name)
        hash
      }
    end
    # End rip

    options.delete(:only) if options[:only].nil? or options[:only].empty?
    hash.each do |key, value|
      if key == "integer_id"
        hash["id"] = value
      elsif key == :item_integer_id
        hash["item_id"] = value
      elsif key == :user_details
        hash["user"] = value
      elsif key == :pros_details
        hash["pros"] = value
      elsif key == :cons_details
        hash["cons"] = value
      elsif key == :activity_user_name
        hash["user_name"] = value
      elsif value.is_a?(Array)
        hash[key] = value.map do |item|
          #item.respond_to?(:as_json) ? item.as_json(options) : item
          item.respond_to?(:as_json) ? item.as_json : item
        end
      elsif value.is_a? BSON::ObjectID
        hash[key] = value.to_s
      elsif value.respond_to?(:as_json)
        if value.is_a?(Time)
          hash[key] = value.utc
        else
          hash[key] = value.as_json(options)
        end
      end
    end

    # Replicate Rails 3 naming - and also bin anytihng after : for use in our dynamic classes from unit tests
    #hash = { ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)).gsub(/:.*/,'') => hash } if include_root_in_json
    hash_key = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)).split(':').first.delete("^[a-z]")
    if hash_key == "review"
      hash = { "hype" => hash }
    elsif hash_key == "labelstat"
      if hash["type"] == "pro"
        hash = { "pro" => hash }
      else #con
        hash = { "con" => hash }
      end
    elsif hash_key == "itemmedia"
      hash = { "image" => hash }
    elsif hash_key == "itemcomment"
      if hash["parent_id"] == "null"
        hash = { "comment" => hash }
      else #reply
        hash = { "reply" => hash }
      end
    elsif hash_key == "activity"
      hash = { "event" => hash }
    else
      hash = { hash_key => hash }  
    end
    hash
  end
end