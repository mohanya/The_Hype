require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'scrobbler'))

Scrobbler::Base::api_key = "cc85b6d4313e40450230872430b4d631";

album = Scrobbler::Album.new('Carrie Underwood', 'Some Hearts', :include_all_info => true)

puts "Album: #{album.name}"
puts "Album ID: #{album.album_id}"
puts "Artist: #{album.artist}"
puts "Playcount: #{album.playcount}"
puts "URL: #{album.url}"
puts "Release Date: #{album.release_date.strftime('%m/%d/%Y')}"

puts
puts

# puts "Tracks"
# longest_track_name = album.tracks.collect(&:name).sort { |x, y| y.length <=> x.length }.first.length
# puts "=" * longest_track_name
# album.tracks.each { |t| puts t.name }
