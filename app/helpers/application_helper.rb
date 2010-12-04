# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def date_string(time)
    time.strftime("%m/%d/%y") if time
  end
  
  def date_time_string(time)
    time.strftime("%m/%d/%y @ %r") if time
  end
  
  def page_title
    title = backwards_title if @flipped
    title ||= partial_title
    title ||= @full_title
    title ||= forwards_title
    
    if Rails.env.development?
      title += " - #{controller.controller_name} : #{controller.action_name}"
    end
    
    case request.request_uri
    when "/"
     title = logged_in? ? "Welcome to The Hype | Home" : title
    when "/users/#{params[:id]}"
     title = logged_in? ? "The Hype | #{User.find(params[:id]).profile.fullname}" : "The Hype | User"
    when "/items"
     title = "The Hype | Browse Items"
    when "/friends/facebook/new"
     title = "The Hype | Find & Invite Friends"
    else
     title
    end 
  end
  
  # Title Item - Controller - Site
  def backwards_title
    title_fields.reverse.join(" - ")
  end
  
  # Site - Controller - Title Item
  def forwards_title
    title_fields.join(" | ")
  end
  
  # Site - Partial Title
  def partial_title
    return nil unless @partial_title
    title = "#{@site.name} - "
    title += @partial_title
  end
  
  def controller_name
    controller = params[:controller].to_s.humanize
    params[:action] == "show" ? controller.singularize : controller
  end
  
  def clean_controller_id(controller)
    controller.gsub(/\//, '_')
  end
  
  def body_id(controller, id)
    body_id = controller == "pages" ? id : controller
    clean_controller_id(body_id) unless body_id.nil?
  end
  
  def production_env?
    RAILS_ENV == 'production'
  end
  

  def score_image_url(score, size='')
    filename = (score.blank? ? "first-hype" : score.to_f)
    root_url + "images/scores/#{"#{size}/" unless size.blank?}#{filename}.png"
  end
  
  def item_tag_cloud(item, ids, classes)
    pro_tags = item.pro_counts(ids).map{|t| t+%w(positive)}
    con_tags = item.con_counts(ids).map{|t| t+%w(negative)}
    pro_counts = pro_tags.transpose[1] || [0]
    con_counts = con_tags.transpose[1] || [0]
    max_count = (con_counts + pro_counts).max    
    
    (pro_tags + con_tags).sort{rand}.each do |tag|
      index = ((tag[1].to_f / max_count) * (classes.size - 1)).round
      yield tag[0], classes[index], tag[2]
    end
  end
  
  def item_tag_cloud_neutral(item, classes)
    tags = item.tags.map{|t| t.tags.flatten + %w(neutral)}
    
    
    tags_counts = tags.transpose[1] || [0]
    max_count = tags_counts.max    
    
    (pro_tags + con_tags).sort{rand}.each do |tag|
      index = ((tag[1].to_f / max_count) * (classes.size - 1)).round
      yield tag[0], classes[index], tag[2]
    end
  end
  
  def safe_time_ago_in_words(val)
    val.nil? ? "Never" : "#{time_ago_in_words(val)} ago"
  end
  
  def short_time_ago_in_words(val)
    time_ago_in_words(val).gsub(/(about )|(over )|(less than a )|(almost )/, '')
  end

  def favorites_link(show=false)
    if  show
      link_to('More', ':javascript;', :class => 'next', :rel => 5)
    end
  end
  
  def last_hype_of_user(user)
    (item = user.last_hype_item) ? "Last Hype: #{link_to(h(item.name[0..14]), item_path(item), :title => h(item.name), :class=>'dropdown')}" : ''
  end
  
  def apropriate_profile_header
    case current_action
    when 'users/edit', 'favorites/edit'
      'Profile'
    when 'profiles/edit', 'passwords/edit', 'passwords/update', 'profiles/social_networks', 'profiles/delete_me', 'profiles/export_my_data','profiles/privacy'
      'Settings'
    when /messages/, /comments/, /notices/
      'Inbox'
    end
  end
  
  def settings_actions
    ['profiles/edit', 'passwords/edit', 'passwords/update', 'profiles/social_networks', 'profiles/delete_me', 'profiles/export_my_data','profiles/privacy']
  end
  
  def selected_tab(*actions)
    actions.include?(current_action) ? 'selected' : ''
  end
  
  def current_action
    controller.controller_name + '/' + controller.action_name
  end

  def link_to_twitter(from = 'wizard')
    if current_user and current_user.twitter? 
      return "<a style='padding-right:10px;' href='/apis/twitter/unlink'><img alt='unlink' src='/images/app/twitter_unlink.png' /></a>"
    else
      return "<a style='padding-right:10px;' href='/apis/twitter/auth?from=#{from}'><img alt='link' src='/images/app/twitter_link.png' /></a>"
    end
  end

  def link_to_share(text, item_id)
    if current_user and current_user.twitter? 
      link_to image_tag('icons/twitter_20.gif'),  apis_twitter_path(:text => text, :item_id => item_id), :class => 'fancybox'
    else
      return "<a href='/apis/twitter/auth?from=#{item_path(item_id)}'><img alt='link' src='/images/icons/twitter_20.gif' /></a>"
    end
  end

  def link_to_bigger_share(text, item_id)
    if current_user and current_user.twitter? 
      link_to image_tag('/images/icons/twitter_30.png'),  apis_twitter_path(:text => text,:item_id => item_id), :class => 'fancybox'
    else
      return "<a href='/apis/twitter/auth?from=#{item_path(item_id)}'><img alt='link' src='/images/icons/twitter_30.png' /></a>"
    end
  end

  def link_to_twitter_profile(user)
    if user.twitter? 
      link_to "Twitter Profile", "http://twitter.com/#{user.get_twitter_name}", :id => 'tw_profile'
    elsif (user == current_user) 
      link_to("+ Add", "/apis/twitter/auth?from=profile") 
    end 
  end
  
  def link_to_facebook_profile(user)
    if user.facebook_user?
      #url = URI.parse("http://graph.facebook.com/#{user.fb_user_id}?fields=link")
      #json = Net::HTTP.get(url)
      #profile_uri = JSON.parse(json)['link']
      #link_to "Facebook Profile", profile_uri, :id => 'fb_profile'
      link = "http://facebook.com/profile.php?id=#{user.fb_user_id}"
      link_to "Facebook Profile", link, :id => 'fb_profile'
    elsif user==current_user
      fb_login_button('window.location = "/users/link_user_accounts";')
    end
  end

  def link_to_facebook
    if current_user and current_user.facebook_user?
      "<a href = 'users/unlink_user_accounts' ><img alt='unlink' src='/images/app/facebook_unlink.png' /></a>"
    else
      fb_login_button('window.location = "/users/link_user_accounts";')
    end
  end
  
  def plural_category_name(category)
    if category.api_source != 'music' && category.api_source != 'web' && category.name!='TV'
      return category.name.singularize.pluralize
    else
      return category.name
    end
  end

  def singular_category_name(category)
    (category.name=='TV' ? category.name.split(",").first.singularize : category.name.split(",").first.singularize.capitalize)
  end
  
  def state_options
    '<option value="AL">Alabama</option>
    	<option value="AK">Alaska</option>
    	<option value="AZ">Arizona</option>
    	<option value="AR">Arkansas</option>
    	<option value="CA">California</option>
    	<option value="CO">Colorado</option>
    	<option value="CT">Connecticut</option>
    	<option value="DE">Delaware</option>
    	<option value="DC">District of Columbia</option>
    	<option value="FL">Florida</option>
    	<option value="GA">Georgia</option>
    	<option value="HI">Hawaii</option>
    	<option value="ID">Idaho</option>
    	<option value="IL">Illinois</option>
    	<option value="IN">Indiana</option>
    	<option value="IA">Iowa</option>
    	<option value="KS">Kansas</option>
    	<option value="KY">Kentucky</option>
    	<option value="LA">Louisiana</option>
    	<option value="ME">Maine</option>
    	<option value="MD">Maryland</option>
    	<option value="MA">Massachusetts</option>
    	<option value="MI">Michigan</option>
    	<option value="MN">Minnesota</option>
    	<option value="MS">Mississippi</option>
    	<option value="MO">Missouri</option>
    	<option value="MT">Montana</option>
    	<option value="NE">Nebraska</option>
    	<option value="NV">Nevada</option>
    	<option value="NH">New Hampshire</option>
    	<option value="NJ">New Jersey</option>
    	<option value="NM">New Mexico</option>
    	<option value="NY">New York</option>
    	<option value="NC">North Carolina</option>
    	<option value="ND">North Dakota</option>
    	<option value="OH">Ohio</option>
    	<option value="OK">Oklahoma</option>
    	<option value="OR">Oregon</option>
    	<option value="PA">Pennsylvania</option>
    	<option value="RI">Rhode Island</option>
    	<option value="SC">South Carolina</option>
    	<option value="SD">South Dakota</option>
    	<option value="TN">Tennessee</option>
    	<option value="TX">Texas</option>
    	<option value="UT">Utah</option>
    	<option value="VT">Vermont</option>
    	<option value="VA">Virginia</option>
    	<option value="WA">Washington</option>
    	<option value="WV">West Virginia</option>
    	<option value="WI">Wisconsin</option>
    	<option value="WY">Wyoming</option>'
  end

  def current_path
    request.request_uri
  end
  
  def all_criteria(item_id)
    item = Item.first(:id => item_id, :select => 'category_id, id')
    case item.category.api_source
      when "product"
        criteria = 'Quality', 'Value', 'Utility'
      when "music-artist"
        criteria = 'Quality', 'Talent', 'Appeal'
      when "music-album"
        criteria = 'Quality', 'Talent', 'Appeal'
      when "music-track"
        criteria = 'Quality', 'Talent', 'Appeal'
      when "movie"
        criteria = 'Quality', 'Value', 'Appeal'
      when "event"
        criteria = 'Quality', 'Value', 'Utility'
      when "person"
        criteria = 'Image',  'Appeal', 'Talent'
      when "place"
        criteria = 'Quality', 'Value', 'Appeal'
      when "web"
        criteria = 'Quality', 'Appeal', 'Utility'
      else
        criteria = 'Quality', 'Value', 'Utility'
      end
  end

  private
  
    def title_fields
      fields = [@site.name]
      fields << (@controller_name || controller_name().capitalize)
      fields << @title_item.to_s unless @title_item.nil?
      fields
    end



end
