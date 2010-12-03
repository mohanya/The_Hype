jQuery(document).ready(function($) {
   $('#tips_holder div.pagination a').live('click', function(event){	
       event.preventDefault();
       var item_id = $.getId();
       var params = $.query(this.href);
       var scope =  params['scope'];
       var page =  params['tips'];
        $('#tips_holder').html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/tips/list", { scope: scope, item_id: item_id, tips: page}, function(data)
        {
          $('#tips_holder').html(data);
      },
    'html'
    );
  return false;
  });
});
