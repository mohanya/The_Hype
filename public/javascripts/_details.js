jQuery(document).ready(function($)
{
  // Carousel for Item Activities
  if ($(".item_activities .activity").length > 4){
    $('.item_activities').jCarouselLite({
       vertical: true,
       visible: 4, 
       start: 0,
       scroll: -1,
       pause: true,
       circular: true,
			 auto: 1500,
			 speed:1000
    });
		 
  }

  $("#additional-images .thumbs .item_image").live('mouseover', function() {
	$(this).siblings('.selected').removeClass('selected');
	$(this).addClass('selected');
	$("#additional-images #preview img").attr('src', $(this).children('span').children('img').attr('alt'));
    });

  $('ul#map_images-select li a').click(function() {
	$('ul#map_images-select li a.selected').removeClass('selected');
        $(this).addClass('selected');
	if('map' == $(this).attr('id'))
	      {
		$('#additional-images').hide();
		$('#map_canvas').show();
	      }
	else
	{
  	  $('#map_canvas').hide();
	  $('#additional-images').show();
	}
	});
});
