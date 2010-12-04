module CommentsHelper
  def comment_subject(comment, link = true, will_truncate = false, max_chars = 50)
    link_label = "Replied to your comment"
    conjunction = " on "
    prefix = "#{link_label} on "
    commentable = self.send("#{comment.class.to_s.underscore}_subject_part", comment, will_truncate, max_chars - prefix.length)
    (link ? link_to(link_label, inbox_comment_path(comment)) : link_label) + conjunction + commentable
  end


  def item_comment_subject_part(comment, will_truncate, max_chars)
    prefix = "item "
    name = will_truncate ? truncate(comment.item.name, :length => max_chars - prefix.length) : comment.item.name 
    prefix + self.link_to(name, item_path(comment.item))
  end
    
  def review_comment_subject_part(comment, will_truncate, max_chars)
    review_link_label = "The Hype"
    conjunction = " for "
    
    prefix = review_link_label + conjunction
    name = will_truncate ? truncate(comment.review.item.name, :length => max_chars - prefix.length) : comment.review.item.name
    link_to(review_link_label, item_review_path(comment.review.item, comment.review)) + conjunction + link_to(name, item_path(comment.review.item))
  end

  def activity_comment_subject_part(comment, will_truncate, max_chars)
    "activity: #{comment.activity.description}"
  end

  def previous_comment_button(comment)
    if c = comment.older_comment
      link_to("", inbox_comment_path(c), :class => "previous")
    else
      '<div class="previous">&nbsp;</div>'
    end
  end

  def next_comment_button(comment)
    if c=comment.newer_comment
      link_to("", inbox_comment_path(c), :class => "next")
    else
      '<div class="next">&nbsp;</div>'
    end
  end

end
