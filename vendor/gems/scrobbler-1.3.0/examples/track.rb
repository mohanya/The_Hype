require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'scrobbler'))
require 'pp'

Scrobbler::Base::api_key = "cc85b6d4313e40450230872430b4d631";

track = Scrobbler::Track.new('Carrie Underwood', :name => 'Before He Cheats', :include_info => true)
puts "Name: #{track.name}"
puts "Album: #{track.album.name}"
puts "Artist: #{track.artist.name}"
puts "Playcount: #{track.playcount}"
puts "URL: #{track.url}"

