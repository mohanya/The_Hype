
function limitChars(textid, infoid, limit)
  {
    var text = textid.val();
    var textlength = text.length;

	if(textlength > limit)
    {
      $(infoid).html('You cannot write more then '+limit+' characters!');
        textid.val(text.substr(0,limit));
      return false;
    }
    else
    {
      //infoid.html(limit - textlength);
      return true;
    }
}


jQuery(document).ready(function() {
	//conversations
    $('#items .conversation_comment .reply_link').live('click', function() {
      var reply_link = $(this);
      var current_comment = $(this).parents('.conversation_comment');
      $(reply_link).hide();
      $.ajax({
        type: "GET",
        url: "/comments/get_form",
        data: {
          id: this.id,
          parent_comment_id: $(current_comment).attr('id')
        },
        success: function(html, status) {
          $(current_comment).after(html);
	  reply_form = $(current_comment).next();
		// We have to bind this since it wasn't in the page when the original .comment_textarea was bound to the event
		$(reply_form).find('.comment_textarea').keyup(function() {
			  limitChars($(this), $(this).siblings('span.word-counter'), 500);
			});
			
			// Bind this as well.
			// Here we define different behavior for subforms after click.
			$(reply_form).find('.reply_button').live('click', function() {
		      send_conversation_form($(this));
		      return false;
		    });
		
		
        }, 
        error: function(xhr, status, ex) {
        }
      });
      return false;
    }); 

	$('.comment_textarea').keyup(function(){
		//alert('yo');
      	limitChars($(this), $(this).siblings('span.word-counter'), 500);
    });
    
    $('#items .conversation_comment_form .cancel_link').live('click', function() {
      $(this).parents('.conversation_comment_form').prev().find('.reply_link').show();
			if ($('.cancel_link').length > 1) {
      $(this).parents('.conversation_comment_form').hide('slow').remove();
			}
			else {
				formId='#'+$($('.cancel_link').parents('form')).attr('id');
				$('.comment_textarea').attr('value','');
				$($(formId+' span').get(0)).hide();
			}
      return false;
    });
    
	
    $('#items .conversation_comment_form .reply_button').live('click', function() {
      send_conversation_form($(this));
      return false;
    });

    $('#items  .like_link').live('click', function() {
      box = $(this).parent('.reply_image');
      $(this).hide();
      $.ajax({
        type: "POST",
        url: "/likes",
        data: {
            id: this.id.replace('like-', ''),
            type: 'Comment'
        },
        success: function(data, status) {
           $(box).html(data);
        }
      });
      return false;
    });

function send_conversation_form(reply_button)
	{
		forme = reply_button.parents('form');
				formeId='#'+forme.attr('id')
				var txtArea=$(formeId+' textarea').attr('value');
				if (txtArea=='' || txtArea=='null') {
					$($(formeId+' span').get(0)).show();
					return false;
				}
				else {
					$($(formeId+' span').get(0)).hide();
				}
             reply_button.hide();
             reply_button.siblings('.wait').show();
	      $.ajax({
	        type: "POST",
	        url: reply_button.parents('form').attr('action'),
	        data: {
	          commentable_id: $(forme).find('#commentable_id').val(),
	          comment_text: $(forme).find('.comment_textarea').val(),
	          parent_comment_id: $(forme).find('#parent_comment_id').val(),
	          commentable_type: $(forme).find('#commentable_type').val(),
	          comment_type: $(forme).find('#comment_type').val()
	        },
	        success: function(html, status) {
	          $('.reply_link').show();
                  reply_button.siblings('.wait').hide();
                  reply_button.show();
	          $(forme).parents('.conversation_comment_form').after(html);
			  $(forme).find('.comment_textarea').val('');

			
				// if this isn't the top form, hide the form and show the reply link
				if(reply_button.parents('span.submit-button').siblings('#parent_comment_id').val() != '')
				{
					$(forme).parents('.conversation_comment_form').remove();
				}
			
	        },
	        error: function(xhr, status, ex) {

	        }
	      });
	}

});
