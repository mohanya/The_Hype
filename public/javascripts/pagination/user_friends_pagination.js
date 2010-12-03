jQuery(document).ready(function($) {
   $('#friendships div.pagination a').live('click', function(event){	
       event.preventDefault();
       var filter = $('#community .select-filter a.selected');
      if($(filter).hasClass('a-global')){
        var scope = 'global';
      } else 
      {
        var scope = 'friends';
      }
       var id = $(filter).attr('id');
       var params = $.query(this.href);
       var page = params['friends_page'];
        $('#friendships').html("<img class='wait' src='/images/wait.gif'/>");
	$.get("/friendships" , {id: id, friends_page: page, scope: scope}, function(data)
        {
          $('#friendships').html(data);
      },
    'html'
    );
  return false;
  });
});
