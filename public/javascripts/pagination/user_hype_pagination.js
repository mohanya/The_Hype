jQuery(document).ready(function($) {
   $('#reviews div.pagination a').live('click', function(event){	
       event.preventDefault();
       var category = $('#reviews .categories a.selected').attr('rel');
       var userid = $('.categories #user_id').text();
       var params = $.query(this.href);
       var page = params['reviews'];
        $('#reviews .user_reviews').html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/partial/hypes/" + userid, {category_id: category, reviews: page}, function(data)
        {
          $('#reviews .user_reviews').html(data);
      },
    'html'
    );
  return false;
  });
});
