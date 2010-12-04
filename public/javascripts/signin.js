jQuery(document).ready(function() {
	function showLabelIfInputBlankOrFocus(input, focused) {
		if (focused || input.val() != '') {
		  input.siblings('label').hide();	
		} else {
		  input.siblings('label').show();	
		}
		
	}
	$('.label_example').livequery(function() {
          $(this).bind('focusin', function(e) {
		showLabelIfInputBlankOrFocus($(this), true);
	}).bind('focusout', function(e) {
		showLabelIfInputBlankOrFocus($(this), false);
	}).bind('change', function(e) {
		showLabelIfInputBlankOrFocus($(this), false);
  }).each(function(){
       showLabelIfInputBlankOrFocus($(this), false);
       $(this).siblings('label').bind('click', function(){
          $(this).hide();
       }).bind('blur', function(){
          $(this).show();
       });
  });
  });


});
