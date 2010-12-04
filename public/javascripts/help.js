
jQuery(document).ready(function($) {

  $('.pros-cons').qtip({
    style:    { name: 'dark', tip: true, width: {min: 360} }, 
    show:     {delay: 0},
    position: { corner: { target: 'topMiddle', tooltip: 'bottomLeft' }, adjust: {x: -105} }
  });

  $(' .option-set .option').qtip({
    style:    { name: 'dark', tip: true}, 
    show:     {delay: 0}
  });

  $('.qtip').each(function(){ 
      target_position = 'topLeft';
      tooltip_position = 'bottomLeft';
      width_adjust = false;
      if($(this).attr('rel')){
        options  = $(this).attr('rel').split('-');
        if (options[0] !=undefined){
          target_position = options[0];
        }
        if ((options[1] !=undefined) && (options[1] !='')){
          tooltip_position = options[1];
        }
        width_adjust = options[2];
      }
      if ( width_adjust == 'min') {
       $(this).qtip({
          style: { name: 'dark', tip: true, width: { min: options[3]} }, 
          show: {delay: 0},
          position: { corner: { target: target_position, tooltip: tooltip_position }}
        });
      }
     else {
     if (width_adjust =='x'){
       $(this).qtip({
        style:    { name: 'dark', tip: true}, 
        show:     {delay: 0},
        position: { corner: { target: target_position, tooltip: tooltip_position }, adjust: {x: - options[3]} }
        });
      }
      else{
       $(this).qtip({
          style: { name: 'dark', tip: true }, 
          show: {delay: 0},
          position: { corner: { target: target_position, tooltip: tooltip_position }}
          });
      }
     }
   });

  $('.help').each(function(){ 
      target_position = 'topLeft';
      tooltip_position = 'bottomLeft';
      target_name = this;
      width_adjust = false;
      if($(this).attr('rel')){
        options  = $(this).attr('rel').split('-');
        if (options[0] !=undefined){
          target_position = options[0];
        }
        if ((options[1] !=undefined) && (options[1] !='')){
          tooltip_position = options[1];
        }
        width_adjust = options[2];
        if ((options[4] !=undefined) && (options[4] !='')){
          target_name = '#' + options[4];
        }
      }
      if ( width_adjust == 'min') {
       $(this).qtip({
          style: { name: 'light', tip: true, width: { min: options[3]} }, 
          show: { when: { event: 'mouseover' } },
          content: { prerender: true},          
          hide: { fixed: true,delay: 140},
          position: { corner: { target: target_position, tooltip: tooltip_position }, target: $(target_name)  }
        });
      }
      else {
         $(this).qtip({
           style:    { name: 'light', tip: true}, 
           show: { when: { event: 'mouseover' } },
           content: { prerender: true},           
           hide: { fixed: true,delay: 140},
           position: { corner: { target: target_position, tooltip: tooltip_position }}
           });
         }
      });
  $('a.tip, input.tip').qtip({
      style:    { name: 'dark', tip: true, width: {min: 400} }, 
      show:     {delay: 0}
  });
});

function insertFlashContent(message) {
  $('#notice').remove();
  $('#top_bar').after("<div id='notice' style='display:none;opacity:0.9;'><div id='notice_wrap'><p><span>" + message + "</span></p></div></div>");
  
  $('#notice').slideDown('slow', function(){
    
	});

  $.timer(7000, function (timer) {
    $('#notice').slideUp('slow', function(){
			$('#notice').remove();
		});
  });

}

