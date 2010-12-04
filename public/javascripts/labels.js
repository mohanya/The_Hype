/*

TagCloud jQuery plugin

A dynamic JavaScript tag/keyword cloud plugin for jQuery, designed to use with Ajax:
the cloud is generated from an array.

MIT license.

Schaffer Krisztián
http://woophoo.com

Usage:
------

Call it on a jQuery object created from one element and pass an array of
objects with "tag" and "count" attributes. E.g.:

var tags = [{tag: "computers", count: 56}, {tag: "mobile" , count :12}, ... ];
$("#tagcloud"}.tagCloud(tags);


Configuration:
--------------
Optionally you can pass a configuration object to tagCloud as the second
parameter. Allowed settings are:

sort: Comparator function used for sort the tags before displaying, or false if
   no sorting needed.

   default: sort by tag text using
          function (a, b) {return a.tag < b.tag ? -1 : (a.tag == b.tag ? 0 : 1)

click: Event handler which receives the tag name as first parameter
   and the original click event as second. The preventDefault() is called
   on event before passing so don't bother.

   default: does nothing:
          function(tag, event) {}


maxFontSizeEm: Size of the largest tag in the cloud in css 'em'. The smallest
   one's size is 1em so this value is the ratio of the smallest and largest
   sizes.

   default: 4


Styling:
--------
 The plugin adds the "tagcloudlink" class to the generated tag links. Note that
an "&nbsp;" is generated between the links too.


Originally based on DynaCloud v3 by
Johann Burkard
<http://johannburkard.de>
<mailto:jb@eaio.com>

CHANGES:
05 sept. 2008
- Improved normalization algorithm - better looking font sizes
- New settings: click, maxFontSizeEm
- Documentation

04 sept. 2008
- Initial version

*/

jQuery.fn.tagCloud = function(cl, givenOptions) { //return this.each( function() { //like a real jQuery plugin: run on on each element
   if (!cl || !cl.length)
      return this;

   // Default settings:
   var defaults = {
      sort: function (a, b) {return a.tag < b.tag ? -1 : (a.tag == b.tag ? 0 : 1)},//default sorting: abc
      click: function(tag) {},
      maxFontSizeEm: 3
   }

   var options = {};
   jQuery.extend(options, defaults, givenOptions);

   // calculating the max and min count values
   var max = -1;
   var min = cl[0].count;
   $.each(cl, function(i, n) {
      max = Math.max(n.count, max);
      min = Math.min(n.count, min);
   });

   if (options.sort) {
      cl.sort(options.sort);
   }

   //Normalization helper
   var diff = ( max == min ? 1    // if all values are equal, do not divide by zero
                           : (max - min) / (options.maxFontSizeEm - 1) ); //optimization: Originally we want to divide by diff
                           // and multiple by maxFontSizeEm - 1 in getNormalizedSize.
   function getNormalizedSize(count) {
      return 1 + (count - min) / diff;
   }

   // Generating the output
   this.empty();
   for (var i = 0; i < cl.length; ++i) {
      var tag = cl[i].tag;
      var tagEl = jQuery('<a href="" class="tagcloudlink" style="font-size: '
                           + getNormalizedSize(cl[i].count)
                           + 'em">' + tag + '<\/a>')
                  .data('tag', tag);

      if (options.click) {
         tagEl.click(function(event) {
            event.preventDefault();
            options.click(jQuery(event.target).data('tag'), event);
         });
      }
      this.append(tagEl).append(" ");
   }
   return this;
//})
}



jQuery(document).ready(function($)
{
	$('a.tag-item').live('click', function() {
		return false;
	});
	
  $("a.tag-item").fancybox({
    'scrolling': 'no',
    'titleShow': false,
    'hideOnOverlayClick': false,
    'padding': 0,
    'autoDimension': true,
    'onClosed': function() {
			//if (typeof($data) != 'undefined') {$.addItemToForm($data);$('#step_1').show()}
		},
    'onComplete': function() {
				
				
				$('#close_label').click(function(){
					$.fancybox.close();
					return false;
				});
				
				$.post('/tag_cloud/' + $('#item_id').val(), $(this).serialize(), function(data) { 
						$("#tag_cloud_canvas").tagCloud(data);
						$.fancybox.resize();
						
						
						$('a.tagcloudlink').click(function() {

		            var tag_option = $(this).text().trim();
								var current_text = $('#tags_string').val();

								if(current_text != '')
								{
									var new_text = current_text + ', ' + tag_option;
								} else {
									var new_text = tag_option
								}

		            $('#tags_string').val(new_text);
		            return false;
		        });
						
						
        	},
	        'json'
	        );
				
				
				$('.new_label').submit(function (){
          //~ $.post($(this).attr('action'), $(this).serialize(), function(data) {
						
						//~ }, 'json'
					//~ );
					//$.fancybox.close();
					//return false;
					//$('#fancybox-inner div.index').css('height', '300px');
					//$('#fancybox-inner').css('height', '330px');
        	//$.fancybox.resize();
				});
     }
    
    });
});
