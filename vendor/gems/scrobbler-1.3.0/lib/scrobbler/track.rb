# Below is an example of how to get the top fans for a track.
# 
#   track = Scrobbler::Track.new('Carrie Underwood', 'Before He Cheats')
#   puts 'Fans'
#   puts "=" * 4
#   track.fans.each { |u| puts u.username }
#   
# Which would output something like:
# 
#   track = Scrobbler::Track.new('Carrie Underwood', 'Before He Cheats')
#   puts 'Fans'
#   puts "=" * 4
#   track.fans.each { |u| puts "(#{u.weight}) #{u.username}" }
# 
#   Fans
#   ====
#   (69163) PimpinRose
#   (7225) selene204
#   (7000) CelestiaLegends
#   (6817) muehllr
#   (5387) Mudley
#   (5368) ilovejohnny1984
#   (5232) MeganIAD
#   (5132) Veric
#   (5097) aeVnar
#   (3390) kristaaan
#   (3239) kelseaowns
#   (2780) syndication
#   (2735) mkumm
#   (2706) Kimmybeebee
#   (2648) skorpcroze
#   (2549) mistergreg
#   (2449) mlmjcace
#   (2302) tiNEey
#   (2169) ajsbabiegirl
module Scrobbler
  class Track < Base
    # Load Helper modules
    include ImageObjectFuncs
    extend  ImageClassFuncs
    
    attr_accessor :artist, :name, :mbid, :playcount, :rank, :url, :id, :count
    attr_accessor :streamable, :album, :date, :now_playing, :tagcount
    attr_accessor :duration, :listeners
    
    # wiki data
    attr_accessor :published, :summary, :description
    
    class << self
      
      def search(name, data={})  
        params = {'track' => name}.merge(data)
        xml = Base.request('track.search', params)
        
        xml.find('/lfm/results/trackmatches/track').map {|track| Scrobbler::Track.new_from_xml(track, {:include_album_info => false, :include_artist_info => false})}
      end
      
      def new_from_xml(xml, o = {})
        data = self.data_from_xml(xml, o)
        return nil if data[:name].nil?
        if data[:artist].blank? 
          if data[:creator].blank? 
            data[:artist] = data[:creator];
          else 
            raise Error, "Supplied XML to track has no artist or creator"
          end
        end
        Track.new(data[:artist], data)
      end
      
      def data_from_xml(xml, o = {})
        o = {:include_album_info => true, :include_artist_info => true}.merge(o) 
        data = {}
        xml.children.each do |child|
          data[:name] = child.content if child.name == 'name' || child.name == 'title'
          data[:mbid] = child.content.to_i if child.name == 'mbid'
          data[:id] = child.content.to_i if child.name == 'id'
          data[:duration] = child.content.to_i if child.name == 'duration'
          data[:url] = child.content if child.name == 'url' || child.name == 'identifier'
          data[:date] = Time.parse(child.content) if child.name == 'date'
          data[:listeners] = child.content.to_i if child.name == 'listeners'
          data[:artist] = Artist.new_from_xml(child, o) if (child.name == 'artist' || child.name == 'creator') && o[:include_artist_info]
          data[:artist] ||= child.content if child.name == 'artist'
          data[:album] = Album.new_from_xml(child, o) if child.name == 'album' && o[:include_album_info]
          data[:playcount] = child.content.to_i if child.name == 'playcount'
          data[:tagcount] = child.content.to_i if child.name == 'tagcount'
          maybe_image_node(data, child)
          if child.name == 'streamable'
            if ['1', 'true'].include?(child.content)
              data[:streamable] = true
            else
              data[:streamable] = false
            end
          end
        end
        
        data[:published] = xml.find_first('/lfm/track/wiki/published').content if xml.find_first('/lfm/track/wiki/published')
        data[:summary] = xml.find_first('/lfm/track/wiki/summary').content if xml.find_first('/lfm/track/wiki/summary')
        data[:description] = xml.find_first('/lfm/track/wiki/content').content if xml.find_first('/lfm/track/wiki/content')
        
        data[:rank] = xml['rank'].to_i if xml['rank']
        data[:now_playing] = true if xml['nowplaying'] && xml['nowplaying'] == 'true'
        
        data[:now_playing] = false if data[:now_playing].nil? 
        o.merge(data)
      end
    end
    
    def initialize(input, data={})
      super()
      #check for old style parameter arguments
      if data.class == String 
        data = {:name => data}
      end
      
      if input.class == String && data[:mbid] && data[:mbid] == true
        raise ArgumentError, "MBID is required for an MBID query" if input.blank?
        @mbid = input
        load_info() unless !data[:include_info].nil? && data[:include_info] == false 
      else
        raise ArgumentError, "Artist is required" if input.blank?
        raise ArgumentError, "Name is required" if data[:name].blank?
        
        @artist = input.is_a?(String) ? Artist.new(input) : input
        @name = data[:name]
        load_info() if data[:include_info]
      end
    end
    
    def add_tags(tags)
      # This function requires authentication, but SimpleAuth is not yet 2.0
      raise NotImplementedError
    end

    def ban
      # This function requires authentication, but SimpleAuth is not yet 2.0
      raise NotImplementedError
    end
    
    @info_loaded = false
    def load_info
      return nil if @info_loaded
      doc = Base.request('track.getinfo', :artist => @artist.name, :track => @name)
      doc.root.children.each do |child|
        next unless child.name == 'track'
        data = self.class.data_from_xml(child)
        populate_data(data)
        @info_loaded = true
        break
      end
    end

    def top_fans(force=false)
      get_response('track.gettopfans', :fans, 'topfans', 'user', {:artist=>@artist.name, :track=>@name}, force)
    end
    
    def similar(force=false, options={})
      get_response('track.getSimilar', :similar, 'similartracks', 'track', {:artist => @artist.name.to_s, :track => @name}.merge(options), force)
    end
    
    def top_tags(force=false)
      get_response('track.gettoptags', :top_tags, 'toptags', 'tag', {:artist=>@artist.name.to_s, :track=>@name}, force)
    end
    
    def buy_links
      if !@info_loaded
        self.load_info
        @info_loaded == true
      end
      
      return @buy_links if @buy_links
      
      @buy_links = []
      
      xml = Base.request('track.getBuyLinks', :artist => @artist.name, :track => @name, :mbid => @mbid, :country => @country)
      
      downloads = xml.find_first('/lfm/affiliations/downloads')
      downloads.children.each do |child|
        @buy_links << Affiliation::new_from_xml(child)
      end
      
      # If wanted later
      #
      #physicals = xml.find_first('/lfm/affiliations/physicals')
      #downloads.children.each do |child|
      #  @buy_links << Affiliation::new_from_xml(child)
      #end
      
      return @buy_links
    end

    def buy_link
      if !@info_loaded
        self.load_info
        @info_loaded == true
      end
      
      return @buy_link if @buy_link
      
      xml = Base.request('track.getBuyLinks', :artist => @artist.name, :track => @name, :mbid => @mbid, :country => @country)
      @buy_link = xml.find_first('/lfm/affiliations/downloads/affiliation/buyLink').content
      
      return @buy_link
    end
    
    def ==(otherTrack)
      if otherTrack.is_a?(Scrobbler::Track)
        return ((@name == otherTrack.name) && (@artist == otherTrack.artist))
      end
      false
    end
  end
end
