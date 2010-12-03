module Wikipedia
  class Client
    @@url = "http://:domain/:path?action=:action&prop=revisions&titles=:page&rvprop=:properties&format=json"
    
    attr_accessor :follow_redirects
    
    def initialize
      self.follow_redirects = true
    end
    
    def find( title )
      title = Url.new(title).title rescue title
      page = Page.new( request( title ) )
      while follow_redirects and page.redirect?
        page = Page.new( request( page.redirect_title ))
      end
      page
    end

=begin
    #wikipedia requires User Agent,
    #replaced with code found here: http://code.google.com/p/wikipedia-client/issues/detail?id=2#c1
    def request( page )
      require 'open-uri'
      #"User-Agent" => "Ruby/#{RUBY_VERSION}"
      URI.parse( url_for(page) ).read
    end
=end


    def request( page )
        require 'net/http'
        uri = URI.parse(url_for(page) )
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header({"User-Agent" => 'The Hype Wikipedia Client'}) # User-Agent should really go in configure
        response = http.request(request)
        response.body
    end
    
    
    protected 
      def url_keys_for( page )
        {
          :domain => Configuration[:domain],
          :path   => Configuration[:path],
          :action => Configuration[:action],
          :page   => URI.encode(page),
          #:user_agent => Configuration[:user_agent], # this didn't work
          :properties => [Configuration[:properties]].flatten.join('|')
        }
      end
      
      def url_for( page )
        ret = @@url.dup
        url_keys_for( page ).each do |key, value|
          ret.sub! ":#{key}", value
        end
        ret
      end
  end
end