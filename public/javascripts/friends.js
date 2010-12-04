function sendFeed(username, user_url) {
  var img_src = "http://test.thehypenetworks.com//images/app/blue_header_logo.png";
  var img_url = "http://www.thehype.com";
  var desc = "www.thehype.com. Discover what the hype is about. Decide if it is worth it or not and Post what you know.";

  var body = "Trying out this new site abt easily sharing consumer knowledge w/ friends. Check out the items I believe are worth the hype by selecting the link below";

  var name = "All-Time Top Hyped Items | " + username;

  var action_links = [{'text':'The Hype', 'href':img_url}];

  var template_data = {
    'name':name,
    'href':user_url,
    'description':desc,
    'media':[{'type':'image', 'src':img_src, 'href':img_url}]
  };

  var callback = function() {
    if (!$('input#auto_post').attr('checked')) {
      alert("Your feed has been sent to Facebook");
    } else {
      return false;
    }
  };

  FB.Connect.requireSession(function() {
    FB.Connect.streamPublish(body, template_data, action_links, '', '', callback, !$('input#auto_post').attr('checked'));
  });
}


  
jQuery(document).ready(function($) {
  var chbox = $('input#auto_post');

  chbox.click(function() {
    if (chbox.attr('checked')) {
      //auto off
    } else {
      //auto on
      FB.Connect.requireSession(function() { 
        FB.Facebook.apiClient.users_hasAppPermission('publish_stream', function(result) {
          if (result == 0) {
            FB.Connect.showPermissionDialog("publish_stream", function() {
              FB.Connect.forceSessionRefresh();
            });
            
          }
        });
      });
    }
  });
  
  $(".friends #facebook_link").click(function() {window.location.href = "/friends/facebook/new";});
  $(".friends #twitter_link").click(function() {window.location.href = "/friends/twitter/new";});
  $(".friends #gmail_link").click(function() {window.location.href = "/friends/contacts/new";});
  $(".friends #back").click(function() {$.fancybox.close();});
  
 
 $('#select_all_fb').click(function() {
          if ($(this).attr('checked')) {
            $('.fb_friends input').attr('checked', true);
          } else {
            $('.fb_friends input').attr('checked', false);
          }
        });
    
    
    $('#select_all_hype').click(function() {
        
        arr = $(this).attr('val').split(',');
        for (var i = 0; i < arr.length; i++) {
        var friend_id = arr[i];
        var ischeck= $(this).attr('checked');
          if(ischeck==true)
          {
           var follow_action="add";
           }
          else
          {
           var follow_action="remove";
          }
          $('.add-to-friends').hide();
          $.ajax({
        type: "POST",
        url: "/users/" + friend_id + "/follow",
        data: {
          id: friend_id,
          follow: ".add-to-friends".id == 'add'
        },
        success: function(html, status) {
         
          follow_selector = 'a[rel^=' +friend_id+'] img';
          for (i=0; i<arr.length; i++) {
            if (follow_action == 'add') {
            $(follow_selector).parents('.add-to-friends#remove1').show()
            }
            else {
            $(follow_selector).parents('.add-to-friends#add').show();
            }
          }
          
          (follow_action == 'add') ? $(follow_selector).parents('.add-to-friends#remove').show() : $(follow_selector).parents('.add-to-friends#add').show();
        },
        error: function(xhr, status, ex) {
          $('div.wait').hide();
        }
        
      });
               //~ return false;
      //~ });
            
         
        }
     
       //~ return false; 
   });

  
  function flash(message) {
    $('#notice').remove();
    $('#top_bar').after("<div id='notice' style='display:block;opacity:0.9;'><div id='notice_wrap'><p><span>" + message + "</span></p></div></div>");

    $.timer(7000, function (timer) {
       $("#notice").fadeTo("slow", 0);
       timer.stop();
    });
  }

  //Twitter

  $('form#twitt_form').ajaxForm({
    dataType: 'json',
    success: function(data) {

      if ($('input#preview_post').attr('checked')) {
        $('form .spinner img').hide();
        $.fancybox.close();
      }

      $('.spinner-main img').hide();
      flash(data['message']);
    } 
  });


  $('form#twitt_form').submit(function() {
    $('div#post_popup form .spinner img').show();
  });

  $('a#auth').click(function() {
    window.location.href = "/apis/twitter/auth";
  });

  $('#preview_post').click(function() {
    if (!$(this).attr('checked') && $('a#new_post').length && !$('a#authorize').length) {
      $('a#new_post').hide();
      $('a#auto_post').show();
      $('#twitt_body').val("Trying out this new site abt easily sharing consumer knowledge w/ friends. http://thehype.com");

    } else if ($(this).attr('checked') && $('a#auto_post').length && !$('a#authorize').length) {
      $('a#new_post').show();
      $('a#auto_post').hide();
    }
  });

  $('#twitt_body').keyup(function() {
    var charCount = $(this).val().length;
    var charsRemaining = 140 - charCount;
    var wordCountLabel = $('div.word-count');
    wordCountLabel.find('em').text(charsRemaining);
    wordCountLabel.css({'color': '#666666'});

    if (charsRemaining < 1) {
      wordCountLabel.css({'color': 'red'});
      $(this).val($(this).val().substring(0,139));
    }
  });

  $('a#auto_post').click(function() {
    $('.spinner-main img').show();
    $('form#twitt_form').submit();
  });

  $('#new_post').fancybox(
    {
    'autoDimensions'  : false,
    'width'           : 600,
    'height'          : 285,
    'padding'         : 0,
    'onStart'         : function() {$('div#post_popup form .spinner img').hide();},
    'onClosed'        : function() {}
    }
  );

  $('#authorize').fancybox(
    {
    'autoDimensions'  : false,
    'width'           : 570,
    'height'          : 190,
    'padding'         : 0,
    'onStart'         : function() {},
    'onClosed'        : function() {}
    }
  );



  // gmail

  $('#preview_email').click(function() {
    if ($(this).attr('checked')) {
      $('#auto_email').hide();
      $('#email_preview').show();
    } else {
      $('#email_preview').hide();
      $('#auto_email').show();
    }
  });



  $('#gmail_auth').fancybox(
    {
    'autoDimensions'  : false,
    'width'           : 530,
    'height'          : 210,
    'padding'         : 0,
    'onStart'         : function() {},
    'onClosed'        : function() {}
    }
  );

  $('#email_preview').fancybox(
    {
    'autoDimensions'  : false,
    'width'           : 680,
    'height'          : 420,
    'padding'         : 0,
    'onStart'         : function() {},
    'onClosed'        : function() {}
    }
  );

  $('#gmail_submit').click(function() {
    $.fancybox.close();
    $('#results-info').remove();
    $('#results-spinner').show();
    $('form#gmail_form').submit();
  });

  $('form#gmail_form').ajaxForm({
    dataType: 'json',
    success: function(data) {
      $('#results-spinner').hide();
      if (data['status'] == 'ok') {
        $.each(data['emails'], function(i) {
          var email_alias = "<div class='email'>" + (!$(this)[0] ? $(this)[1] : $(this)[0]) + "</div>";
          var email = $(this)[1];

          $('form .results').append("<div class='contact-item'><input id='emails_' type='checkbox' value='"+ email +"' name='emails[]' />"+email_alias+"<span>" + $(this)[2] + "</span><div class='clear'></div></div>");

        });

        $('.invites_submit').attr('disabled', true);

        $('#select_all').click(function() {
          if ($(this).attr('checked')) {
            $('.contact-item input').attr('checked', true);
          } else {
            $('.contact-item input').attr('checked', false);
          }
        });

      } else {
        flash(data['message']);
      }
    }
  });

  $('form#invites_form').ajaxForm({
    dataType: 'json',
    success: function(data) {
      $('#spinner2').hide();
      $.fancybox.close();
      flash(data['message']);     
    }
  });


  $('.invites_submit').click(function() {
    if ($('.contact-item input:checked').length) {
      $('#email_body').val($('#email_body_preview').val());

      $('#spinner2').show();
      $('form#invites_form').submit();
    } else {
      return false;
    }
  });

});
