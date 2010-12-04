jQuery(document).ready(function() {
  $("#add_tip").find('#submit_tip').live('click', function() {
      form = $(this).parents('form'); 
      $(this).hide();
	      $.ajax({
	        type: "POST",
	        url: $(form).attr('action'),
	        data: {
	          advice: $(form).find('#tip_advice').val()
	        },
	        success: function(html, status) {
                  $('.error_info').remove();
                  $('#tips_holder .tipsy').remove();
	          $('#tips_holder').prepend(html);
                  $(form).find('#tip_advice').val('');
                  $(form).find('#submit_tip').show();

	        },
	        error: function(xhr, status, ex) {

	        }
	      });
              return false;

  });
  $('#tips_holder').find('.voting').live('click', function(){
      var vote=$(this).attr('rel');
      tip = $(this).parents('.tip_vote');
	      $.ajax({
	        type: "POST",
	        url: '/tips/vote',
	        data: {
	          vote: vote,
                  id: tip.attr('rel')
	        },
	        success: function(html) {
                  $(tip).find('.tip_score').html(html);
                }
                });
              return false;
  });
});
