function search_user_hypes(user_id, category, div_target){
        div_target.html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/partial/hypes/" + user_id, {category_id: category}, function(data)
  {
    div_target.html(data);
  },
  'html'
  );
}

jQuery(document).ready(function($) {

		$('.categories a.set_hypes_category').click(function(){	
		 	$('.categories a.selected').removeClass('selected');
		 	$(this).addClass('selected');
		 	var category_id = $(this).attr('rel');
		 	search_user_hypes($('.categories #user_id').text(), category_id, $('#reviews .user_reviews'));
		 	return false;
		});

  $.timer(500, function (timer) {
    $('#user-vitals a#RES_ID_fb_login').text('+ Add');
    if ($('#user-vitals a#RES_ID_fb_login').text() == '+ Add'){;
      timer.stop();
    }
  })
});
