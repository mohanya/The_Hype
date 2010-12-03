###############################################################################
# Search / Sunspot setup
###############################################################################

# Create the adapter (we are building this ourselves)
module MongoAdapter
  class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      @instance.id
    end
  end

  class DataAccessor < Sunspot::Adapters::DataAccessor
    def load(id)
      @clazz.find(id)
    end

    def load_all(ids)
      @clazz.all(:id => ids)
      # all = @clazz.all(ids.map { |id| id.to_i })
      # if @custom_title
      #   all.each { |item| item.title = @custom_title }
      # end
      # all
    end
    # 
    # def custom_title=(custom_title)
    #   @custom_title = custom_title
    # end
  end
end