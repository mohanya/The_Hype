jQuery(document).ready(function() {
    if ($('#the-stream').length){
      Stream.setup();
      Stream.show_activity();
      $.timer(250000, function(){
         Stream.get_activity();
      });
    }

    $('.stream-li .conversation_comment_form .cancel_link').live('click', function() {
      $(this).parents('.stream-li').find('.reply_link').show();
      $(this).parents('.conversation_comment_form').hide('slow').remove();
      return false;
     });


    $('.activity_content .like_link').live('click', function() {
      $(this).hide();
      var target = $(this).attr('rel');;
      $.ajax({
        type: "POST",
        url: "/likes",
        data: {
            id: this.id.replace('like-', ''),
            type: 'Activity'
        },
        success: function(html, status) {
          $('#' + target).show();
          $('#' + target).find('.like-box').show().html(html);
        }
      });
      return false;
    });

    $('.reply-box .replies').live('click', function() {
      $(this).parent('li').hide();
      var target = $(this).parent().parent().attr('id');
      $.ajax({
        type: "GET",
        url: "/activities/more",
        data: {
            id: target.replace('box-', '')
        },
        success: function(html, status) {
          $(html).insertBefore($('#' + target).children('.clear'));
        }
      });
      return false;
    });

    $('.activity_content .reply_link').live('click', function() {
      $(this).hide();
      var current_comment = $(this).parents('.activity_content');
      $.ajax({
        type: "GET",
        url: "/activities/reply_form",
        data: {
          id: this.id.replace('reply-', ''),
          parent_comment_id: $(current_comment).attr('id').replace('ac-', '')
        },
        success: function(html, status) {
          reply = $(current_comment).siblings('.reply-box');
          $(html).insertBefore($(reply));
          text = $(current_comment).siblings('.conversation_comment_form').find('.comment_textarea');
          $(text).focus();
			$(text).keyup(function() {
			  limitChars($(this), $(this).siblings('span.word-counter'), 500);
			});
			
			$('.reply-button').live('click', function() {
		      send_reply_form($(this));
		      return false;
		    });
		
		
        }, 
        error: function(xhr, status, ex) {
          
        }
      })
      return false;
    }); 

    $('#activities .conversation_comment_form .reply_button').live('click', function() {
      send_reply_form($(this));
      return false;
    });

  function send_reply_form(reply_button){
  	var form = reply_button.parents('form');
             reply_button.hide();
             reply_button.siblings('.wait').show();
	      $.ajax({
	        type: "POST",
	        url: reply_button.parents('form').attr('action'),
	        data: {
	          commentable_id: $(form).find('#commentable_id').val(),
	          comment_text: $(form).find('.comment_textarea').val(),
	          parent_comment_id: $(form).find('#parent_comment_id').val(),
	          comment_type: $(form).find('#comment_type').val(),
	          commentable_type: $(form).find('#commentable_type').val()
	        },
	        success: function(html, status) {
	          $('.reply_link').show();
                  reply_button.siblings('.wait').hide();
                  reply_button.show();
                  var reply_box = $(form).parent('.conversation_comment_form').siblings('.reply-box');
                  $('.conversation_comment_form').remove();
                  $(reply_box).show();
                  $(html).insertBefore($(reply_box).children('.clear'));
			
	        },
	        error: function(xhr, status, ex) {

	        }
	      });
	}
});
var Stream = {
 last_update: new Date(),
  
  setup: function(){
    this.last_update = new Date();
  },

  get_activity: function(){
      var global = $('#the-stream .select-div .selected').hasClass('a-global');
      var last_value = $('#the-stream #live_count').text();
      var time = Stream.last_update;
      var scope = 'friends';
       if (global){
         scope  = 'global';
       }
      var res = $.ajax({
        type: "GET",
        url: "/activities/latest",
        data: {
            time: time,
            scope: scope
        },
        success: function(html, status) {
            if ((html != 0) && (html != last_value)){
              $('#the-stream #live_update').show();
              $('#the-stream #live_count').text(html).show();
            }
        }
      });
  }, 
  
  show_activity: function(){

    $('.live-stream').live('click', function() {
      var global = $('#the-stream .select-div .selected').hasClass('a-global');
      var time = Stream.last_update;
      var scope = 'friends';
       if (global){
         scope  = 'global';
       }
      var count = $('#the-stream #live_count').text();
      $(this).parent().hide();
      $('#the-stream #live_count').text('');
      var res = $.ajax({
        type: "GET",
        url: "/activities/show_latest",
        data: {
            time:  time,
            scope: scope
        },
	 success: function(html, status) {
            $('#activities').prepend(html);
            Stream.last_update = new Date();
             // Remove too many elemnts
              var new_amount = $('#activities li.stream-li').size();
              if (new_amount > 15){
                for (var i=0; i < (new_amount - 15); i++){
                  $('#activities li:last-child').remove();
                  $('#activities li:last-child').remove();
                   }
                }

         }

      });
    });
  }
};
