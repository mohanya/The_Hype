module Scrobbler
  # @todo everything
  class Playlist < Base
    # Load Helper modules
    include ImageObjectFuncs
    extend  ImageClassFuncs
    
    attr_reader :url, :id, :title, :date, :creator
    attr_reader :description, :size, :duration, :streamable
    class << self
      
      def url_for_album(album_id)
        "lastfm://playlist/album/"+album_id.to_s
      end
      
      def url_for_playlist(playlist_id)
        "lastfm://playlist/album/"+playlist_id.to_s
      end
      
      def new_from_album(album)
        pp album.class
        raise ArgumentError, "Must create a playlist from an album object" if album.class != Scrobbler::Album
        Playlist.new(url_for_album(album.album_id))
      end
      
      def new_from_xml(xml)
        data = data_from_xml(xml)
        puts "Creating Playlist: #{data[:title]}"
        return nil if data[:title].nil?
        Playlist.new(data[:url],data)
      end
      
      def data_from_xml(xml, o = {})      
        o = {:include_track_info => true}.merge(o)
        data = {}
        xml.children.each do |child|
          data[:id] = child.content.to_i if child.name == 'id'
          data[:title] = child.content if child.name == 'title'

          maybe_image_node(data, child)
          data[:date] = Time.parse(child.content) if child.name == 'date'

          data[:size] = child.content.to_i if child.name == 'size'
          data[:description] = child.content if child.name == 'description'
          data[:duration] = child.content.to_i if child.name == 'duration'

          if child.name == 'streamable'
            if ['1', 'true'].include?(child.content)
              data[:streamable] = true
            else
              data[:streamable] = false
            end
          end
          
          if child.name == 'trackList'
            data[:tracks] = []
            child.children.each do |grandchild|
              data[:tracks] << Track.new_from_xml(grandchild, o) if grandchild.name == 'track'
            end
          end
          data[:creator] = child.content if child.name == 'creator'
          data[:url]     = child.content if child.name == 'url'
        end
        data
      end
    end
  
    def initialize(url,data={})
      @url = url
      fetch() unless data[:include_info] && data[:include_info] == false
    end
    
    def fetch() 
      #Since playlists aren't static in the same sense the other objects are, dont cache results, always fetch the lastest version.
      xml = Base.request('playlist.fetch', {:playlistURL => @url});
      unless xml.root['status'] == 'failed'
        xml.root.children.each do |child|
          next unless child.name == 'playlist'
          data = self.class.data_from_xml(child, {:include_track_info => false, :include_album_info => false})
          populate_data(data)
          break
        end # xml.children.each do |child|
      end
    end
  end
end

