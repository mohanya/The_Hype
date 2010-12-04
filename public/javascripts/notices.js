/*
 *
 *	jQuery Timer plugin v0.1
 *		Matt Schmidt [http://www.mattptr.net]
 *
 *	Licensed under the BSD License:
 *		http://mattptr.net/license/license.txt
 *
 */
 
 jQuery.timer = function (interval, callback)
 {

	var interval = interval || 100;

	if (!callback)
		return false;
	
	_timer = function (interval, callback) {
		this.stop = function () {
			clearInterval(self.id);
		};
		
		this.internalCallback = function () {
			callback(self);
		};
		
		this.reset = function (val) {
			if (self.id)
				clearInterval(self.id);
			
			var val = val || 100;
			this.id = setInterval(this.internalCallback, val);
		};
		
		this.interval = interval;
		this.id = setInterval(this.internalCallback, this.interval);
		
		var self = this;
	};
	
	return new _timer(interval, callback);
};

/*
 * flash notice functionality
 * Currently this is the only script using Timer Plugin
 * Thomas Wright
 */

$(document).ready(function()
{
  $('#notice, #warning').slideDown('slow', function(){
		
	});
  
  $("#notice, #warning").click(function()
  {
		$(this).slideUp('slow', function(){
			$(this).remove();
		});
  });
  
  //~ $.timer(7000, function (timer) {
		//~ $('#notice, #warning').slideUp('slow', function(){
			//~ $(this).remove();
		//~ });
	$.timer(2000, function (timer) {
		$('#notice, #warning').fadeOut(3000, function(){
			$(this).slideUp('slow');
			$(this).remove();
		});

    timer.stop();
  });
});
