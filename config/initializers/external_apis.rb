api_data = YAML::load(File.read(RAILS_ROOT + "/config/external_apis.yml"))

#Last.fm
Scrobbler::Base::api_key = api_data['lastfm']['api_key']

#Upcoming.org
Upcoming.api_key = api_data['upcoming']['api_key']

#themoviedb.org
@@tmdb = TMDBParty::Base.new(api_data['moviedb']['api_key'])

require "googleajax"
#google AJAX
GoogleAjax.referer = api_data['googleajax']['referer']
GoogleAjax.api_key = api_data['googleajax']['api_key']
