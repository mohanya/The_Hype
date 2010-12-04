jQuery(document).ready(function($) {
   $('#reviews div.pagination a').live('click', function(event){	
       event.preventDefault();
       var category = $('#reviews .categories a.selected').attr('rel');
       var item_id = $.getId();
       var params = $.query(this.href);
       var page =  params['reviews'];
       var scope =  params['scope'];
        $('#reviews .clearfix').html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/reviews/list", {scope: scope, item_id: item_id, reviews: page}, function(data)
        {
          $('#reviews .clearfix').html(data);
      },
    'html'
    );
                         
  return false;
  });
});
