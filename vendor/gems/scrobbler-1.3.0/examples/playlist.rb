require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'scrobbler'))
require 'pp'

Scrobbler::Base::api_key = "cc85b6d4313e40450230872430b4d631";

playlist = Scrobbler::Playlist.new('lastfm://playlist/album/2317937')
pp playlist