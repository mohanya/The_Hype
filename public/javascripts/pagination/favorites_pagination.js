jQuery(document).ready(function($) {
  $('#top_hypes a.next').bind('click', function(event){	
    event.preventDefault();
    parent_box = $(this).parents('.fav_box');
    var category = $(parent_box).attr('rel');
    var offset = $(this).attr('rel');
    var userid = $('.categories #user_id').text();
    show_link = $(parent_box).find('.show_link');
    $(show_link).find('a').hide();
    $(show_link).append("<img class='wait next' src='/images/wait.gif'/>");
    $.get("/users/" +userid + "/favorites", {category_id: category, offset : offset}, function(data)
      {
          if (jQuery.trim(data) != ''){
            $(show_link).before('<div class="more_favorites">' + data + '</div>');
            $(parent_box).find('.wait').remove();
            $(show_link).find('a').text('Less').attr('rel', '0').show();
          }
          else{
            $(parent_box).find('.more_favorites').remove();
            $(parent_box).find('.wait').remove();
            $(show_link).find('a').text('More').attr('rel', '5').show();
          }

      },
    'html'
    );
  return false;
  });
});
