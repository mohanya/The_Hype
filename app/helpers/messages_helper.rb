module MessagesHelper
  
  def previous_message_button(message)
    if m = message.older_message
      link_to("", inbox_message_path(m), :class => "previous")
    else
      '<div class="previous">&nbsp;</div>'
    end
  end

  def next_message_button(message)
    if m= message.newer_message
      link_to("", inbox_message_path(m), :class => "next")
    else
      '<div class="next">&nbsp;</div>'
    end
  end

  def will_paginate_messages(messages)
    [
      '<div class="pagination">',
      previous_page_link(messages),
      next_page_link(messages),
      '</div>'
    ].join('')
  end

  def previous_page_link(messages)
    if messages.current_page > 1 and messages.current_page <= messages.total_pages
      link_to('', url_for(:page => messages.current_page - 1), :class => 'previous')
    else
      '<div class="previous">&nbsp;</div>'
    end
  end

  def next_page_link(messages)
  if messages.current_page < messages.total_pages and messages.current_page >= 1
      link_to('', url_for(:page => messages.current_page + 1), :class => 'next')
    else
      '<div class="next">&nbsp;</div>'
    end
  end

  def showing_unread?
    request.path_parameters[:action] == 'unread'
  end

  def inbox_element_dom_class(inbox_element)
    "inbox-element" + (inbox_element.read? ? ' read' : ' unread')
  end
end

