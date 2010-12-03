module Friends::FacebooksHelper
  #~ def fb_feed(user)
    #~ user = user.name.gsub("'", " ").gsub("\r\n", " ").gsub("\n", " ")
    #~ button = image_tag("app/facebook_link.png")
    #~ user_url = root_url.chop + user_path(user)

    #~ return "<a href='javascript:;', onclick=\"sendFeed('#{user}', '#{user_url}')\">"+button+"</a>"
  #~ end
  
  def fb_feed(user)
    user = user.name.gsub("'", " ").gsub("\r\n", " ").gsub("\n", " ")
    button = image_tag("app/Invite_friends.png")
    user_url = root_url.chop + user_path(user)

    return "<a href='javascript:;', onclick=\"sendFeed('#{user}', '#{user_url}')\">"+button+"</a>"
  end

  def selected(name)
    case params[:controller]
    when 'friends/facebooks' 
      'border-bottom: 3px solid #1876BD' if name == 'facebook'
    when 'friends/twitters'
      'border-bottom: 3px solid #1876BD' if name == 'twitter'
    when 'friends/contacts'
      'border-bottom: 3px solid #1876BD' if name == 'gmail'
    end
  end
end
