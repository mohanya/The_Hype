jQuery(document).ready(function($) {
   $('#all-items div.pagination a').live('click', function(event){	
       event.preventDefault();
       var item_id = $.getId();
       var params = $.query(this.href);
       var page =  params['page'];
       var scope =  params['scope'];
       var category =  params['category'];
       var sort =  params['sort'];
        $('#all-items #browse').html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/items/list", {sort: sort, scope: scope, category: category, page: page}, function(data)
        {
          $('#all-items #browse').html(data);
      },
    'html'
    );
  return false;
  });
});
