module ItemDetailsHelper
  def render_item_detail_value(value)
    if value.is_a? Array
      value.collect {|v| content_tag(:dd, v)}.join
    else
      content_tag(:dd, value)
    end
  end
end
