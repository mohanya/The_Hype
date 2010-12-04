module UsersHelper
  def split_by_length(text, max_length)
    splits = ['']
    text.chars.each do |character|
      splits << '' if splits.last.length >= max_length
      splits.last << character
    end
    splits
  end

  def split_words_by_length(text, max_length)
    text.split.map { |word| split_by_length(word, max_length) }.flatten.join(' ')
  end
  def more_less(text)
    [
      '<span class="more_less">',
      if text.length <= 140
        text
      else
        first_part = text[0...140]
        second_part = text[140..-1]
        [
          first_part,
          "<span class=\"ellipse\">... </span>",
          "<span class=\"more\">#{second_part}</span>",
          link_to('more', '#', :class => 'more_less_link'),
        ].join('')
      end,
      '</span>'
    ].join('');
      
  end

  def step_state(current_step, step_name)
    steps = ['favourites', 'profile', 'settings', 'congrats']
    case steps.index(current_step) <=> steps.index(step_name)
    when 1
      'done'
    when 0
      'active'
    when -1 
      'todo' 
    end
  end
  
  def tag_list(interests)
    count = interests.count + 1
    interests.map do |interest|
      OpenStruct.new(interest.attributes.merge({:count => count - interest.pos}))
    end.shuffle
  end
  
  def unknown_if_blank(value)
    value.blank? ? "unknown" : value
  end
  
  def blank_section_text(user, path)
    [
      '<div class="unknown">',
      current_user == user ? "Select the 'Complete It' button to finish your Profile" : '&nbsp;',
      '</div>'
    ].join('')
  end
  
  def signup_progress_bar(percent)
    percent_string = "#{percent.to_s}%"
    "<div id=\"signup-progress-bar\"><div class=\"bar\" style=\"width: #{percent_string};\"><div class=\"percent\">#{percent_string}</div></div></div>"
  end
  
  def has_any_essentials?(user)
    user.essentials.any? { |e| !e.new_record? }
  end
  
  def edit_link_if_current(user, path = nil, link_label = "Edit")
    current_user == user ? link_to(link_label, path || edit_user_path(user)) : ''
  end  
  
  def hypes_count(user_id, category_id)
    parent = ItemCategory.find(category_id)
    if parent.children.length > 0
      category_ids = [category_id] + parent.children.collect(&:id).to_a
      count=Review.count(:user_id => user_id, :item_category_id => {'$in' => category_ids})
    else
      count = Review.count(:user_id => user_id, :item_category_id => category_id)
    end
    return count.to_s
  end

  def complete_it_destination_path
    if current_user.top.count < ItemCategory.count(:conditions =>{:parent_id => nil})
      edit_user_favorites_path(current_user)
    elsif has_any_blank_profile_field?(current_user) || has_any_blank_essential?(current_user)
      edit_user_profile_path(current_user)
    elsif does_not_have_avatar?(current_user)
      scope_path(current_user, :scope => 'settings')
    else
      scope_path(current_user, :scope => 'congrats')
    end
  end
  
  def years_ago_in_words(date)
    date ||= Time.now
    distance_in_years = (Time.now.year - date.year)
    "#{distance_in_years} y.o."
  end
  private
  def has_any_blank_profile_field?(user)
    required_fields = %w[country city education_level job about_me trusted_brand_list interest_list]
    required_fields.detect { |attrib| user.profile.send(attrib).blank? } 
  end
  
  def does_not_have_avatar?(user)
    !user.profile.avatar?
  end
  
  def has_any_blank_essential?(user)
    user.essentials_count < Essential.essential_categories.count
  end
  
  def error_messages_for_all user
    msg=[]    
    msg_cant=[]
    errors_field=error_messages_for :user    
    if errors_field!="" 
    er2_split=errors_field.split("<ul>")[1].split("</ul>")[0].split("</li>")
    for i in 0..er2_split.length-1
      msg[i]=er2_split[i].gsub(/<\/?[^>]*>/,"")
    end
    for count in 0..msg.length-1
      if msg[count].include?("can't")
        msg_cant<<msg[count]
      end
    end  

    for i in 0..msg_cant.length-1
      msg_sub=msg_cant[i].split(" ")
      arr=[]
      for j in 0..msg.length-1 
        if msg[j].include?(msg_sub[0])
          msg[j]=""      
        end
      end     
    end
      
      msg.each do |value|
        if value==""
          msg.delete(value)
        end
      end 
    msg_actual=msg+msg_cant
    
    list="<div id='errorExplanation' class='errorExplanation'><h2>"+msg_actual.count.to_s+"errors prohibited this user from being saved</h2></br>"
    list=list+"<p>There were problems with the following fields:</p></br>"
    list=list+"<ul>"
    for count in 0..msg_actual.length-1
      list=list+"<li>"+msg_actual[count]+"</li>"
    end
    list=list+"</ul>"
    list=list+"</div>"    
    list    
    else
      ''
    end
  end
end
