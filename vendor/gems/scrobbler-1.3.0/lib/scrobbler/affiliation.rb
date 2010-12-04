module Scrobbler
  class Affiliation < Base
    
    attr_accessor :supplier_name, :buy_link, :supplier_icon, :is_search

    
    class << self      
      
      def new_from_xml(xml, o={})
        data = data_from_xml(xml, o)
        Affiliation.new(data)
      end
      
      def data_from_xml(xml, o={})
        data = {}
        # Get all information from the root's children nodes
        xml.children.each do |child|
          data[:supplier_name] = child.content.to_i if child.name == 'suppliername'
          data[:buy_link] = child.content if child.name == 'buylink'
          data[:supplier_icon] = child.content if child.name == 'suppliericon'
          data[:is_search] = child.content.to_i if child.name == 'issearch'
        end        
        return data
      end
    end
    
    def initialize(data = {})
      super()
      populate_data(data)
    end

    @info_loaded = false
    # Get the metadata
    def load_info
        doc = Base.request('artist.getinfo', {'artist' => @name})
        doc.root.children.each do |child|
            next unless child.name == 'artist'
            data = self.class.data_from_xml(child)
            populate_data(data)
            @info_loaded = true
            break
        end
    end # load_info
    
  end
end
