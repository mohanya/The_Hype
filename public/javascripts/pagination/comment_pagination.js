jQuery(document).ready(function($) {
   $('#conversations div.pagination a').live('click', function(event){	
       event.preventDefault();
       var item_id = $.getId();
       var params = $.query(this.href);
       var page =  params['comments'];
       var scope =  params['scope'];
        $('#conversations .conversation_wrapper .pag').html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/comments/list", {scope: scope, item_id: item_id, comments: page}, function(data)
        {
          $('#conversations .conversation_wrapper .pag').html(data);
      },
    'html'
    );
  return false;
  });
});
