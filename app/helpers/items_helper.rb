module ItemsHelper
  def display_conversation(comments)
    ret = ""
    comments.each do |comment|
      if comment.parent_id == 0 || comment.parent_id.blank?
        ret += display_comment(comment)
        ret += display_children(comment)
      end
    end
    ret
  end

  def display_children(comment)
    ret = ""
    if comment.children.size > 0
      comment.children.each do |child_comment| 
        if child_comment.children.size > 0
          ret += display_comment(child_comment)
          ret += display_children(child_comment)
        else
          ret += display_comment(child_comment)
        end
      end
    end
    ret
  end
  
  def display_comment(comment)
    render :partial => 'items/conversation', :object => comment
  end
  
  def item_image_with_link(item)
    if item.new_record?
      link_to image_tag(item.basic_image_url.to_s), '/search?query=' + item.name, :title => item.short_description
    else
      link_to image_tag(item.thumb_image), item_path(item.id), :title => item.short_description
    end
  end

  def link_for_item(item)
    if item.new_record?
      link_to truncate(item.name.to_s, :length => 15), '/search?query=' + item.name
    else
      link_to truncate(item.name.to_s, :length => 15), item_path(item.id)
    end
  end
  
  def item_text_link(item)
    if item.new_record?
      link_to item.name, '/search?query=' + item.name, :title => item.short_description
    else
      link_to item.name, item_path(item.id), :title => item.short_description
    end
  end
  
  def full_url(url)
     without_http = url.gsub(/^http:\/\// , '')
     return "http://#{without_http}" 
  end
end
