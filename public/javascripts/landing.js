jQuery(document).ready(function($){
  $("a.fancybox").fancybox({
    'autoDimensions': false,
     'height' : 240,
     'width' : 480,
     titleShow: false

  });

  $("#new_invite").submit( function(){
     $.ajax({
         type: "POST",
         data:  $(this).serialize(),
         url:  $(this).attr("action"),
          success: function(data){
             $.fancybox(data, {
              'autoDimensions': false,
               'height' : 240,
               'width' : 480,
               titleShow: false
             });
          }
     });
     return false;
  });

  $("#resend_button").live('click', function(e){
    e.preventDefault();
    var href = $("#resend_button").attr('href');
    $("#resend_button").replaceWith("<img class='wait next' src='/images/wait.gif'/>");
    $.get(href, {}, function(data){ $("#fancybox-inner").html(data); });
  });
});
