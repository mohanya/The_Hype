function search_images(query, start, div_target)
{
  div_target.append("<img class='" + div_target.attr("id") + "_wait' src='/images/wait.gif' style='clear: left;' />");

  $.get("/searches/image", {query: query, start: start}, function(data)
  {
    div_target.append(data);
    $("img." + div_target.attr("id") + "_wait").hide();
  },
  'html'
  );
}

jQuery(document).ready(function($)
{
 var start_count = 0;
			// Load more images
			$('#load_more_images').live('click', function(){
				search_images($('#search_term').val(), start_count, $('#image_search_results'));
				start_count++;
				return false;
			});

                        $("#primary_image").val($(".selected_primary").attr('alt'));
			// On double click make it the primary.
			$('.search_image').live("dblclick", function(){
				$('#image_search_results img.selected_primary').removeClass('selected_primary');
				$(this).addClass('selected_primary');
						$(this).removeClass('selected_image');
						$(this).siblings('input:checkbox').attr('checked', false);
						$('#primary_image').val(this.alt);
                                                $("#existing_primary_image").remove();
			});
      

			// On single click toggle select
			$('.search_image').live("click", function(){
				if($(this).hasClass('selected_image'))
				{
					$(this).removeClass('selected_image');
					$(this).siblings('input:checkbox').attr('checked', false);
				}
				else
				{
					if(!$(this).hasClass('selected_primary'))
					{
						$(this).addClass('selected_image');
						$(this).siblings('input:checkbox').attr('checked', 'checked');
					}
				}
			});
});
