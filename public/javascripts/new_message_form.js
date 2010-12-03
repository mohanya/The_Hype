jQuery(document).ready(function($)
{
  $('#messages-index .filter li a, #inbox-menu li a').bind('mouseenter', function(e){
    $(this).closest('li').addClass('highlighted');
    return false;
  }).bind('mouseleave', function(e){
    $(this).closest('li').removeClass('highlighted');
    return false;
  });
	$('#new-message-button, .message-reply-link').fancybox({
		autoScale: false,
    autoDimensions: false,
    width: 660,
    height: 402,
    padding: 0,
    onComplete: function(){
         allow_search();
          if(_myOwnObject.allow==2) {
            $('#fancybox-title').hide();
            $("#fancybox-left").hide();
            $("#fancybox-right").hide();
          }
    }
  });
  $("#new-message-popup #new_message").submit(function() {
      $(this).find('#message_submit').attr("disabled", "true");
      $.ajax({
        url : '/inbox/messages',
        type: "POST",
        data :  $(this).serialize() ,
        success: function(html, status) {
               $.fancybox(html,
               {
                autoScale: false,
                autoDimensions: false,
                width: 660,
                height: 440,
                padding: 0,
                onComplete: function(){
                               allow_search();
                } 
               }
               );
        }
        });
      return false;
  });

  $('#cancel-new-message').click(function(e){
      $.fancybox.close();
      return false;
  });

  $('#message-reply-toggle-link').click(function(e){
    $('.inline-reply-form').toggle();
    return false;
  });
});

function allow_search(){
      var receiverSearch = $('#receiver_autocomplete');
      receiverSearch.autocomplete('/users/mutual_friends', {
        mustMatch : false,
        cacheLength: 1,
        max: 10,
        scroll: false,
        selectFirst: false
      });
      receiverSearch.result(function (event, data, formatted) {
      	$(this).siblings('#message_receiver_id').val( !data ? '' : data[1]);
      });
}
