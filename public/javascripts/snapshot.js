jQuery(document).ready(function($)
{
    $("a#snapshot-link, a#meter-snapshot-link").fancybox({
       'titleShow' : false,
       'autoDimensions' : false,
       'onStart' : function(){
         $('#fancybox-wrap').addClass('graph');
       },
       'onClosed' : function(){
         $('#fancybox-wrap').removeClass('graph');
       },
       'height' : 380,
       'width' : 800
    });
    
    $("a#pie-snapshot-link").fancybox({
       'titleShow' : false,
       'autoDimensions' : false,
       'onStart' : function(){
         $('#fancybox-wrap').addClass('graph');
       },
       'onClosed' : function(){
         $('#fancybox-wrap').removeClass('graph');
       },
       'onComplete' :function(){ 
          $('.navigation ul.clearfix:last li a').removeClass('selected');
          $('#meter').hide();
          $('#buzz').hide();
          $('#sentiment').show();
          $('.navigation ul.clearfix:last li.sentiment a').addClass('selected');
         },
       'height' : 380,
       'width' : 800
    });
    
    $("a#buzz-snapshot-link").fancybox({
       'titleShow' : false,
       'autoDimensions' : false,
       'onStart' : function(){
         $('#fancybox-wrap').addClass('graph');
       },
       'onClosed' : function(){
         $('#fancybox-wrap').removeClass('graph');
       },
       'onComplete' :function(){ 
          $('.navigation ul.clearfix:last li a').removeClass('selected');
          $('#meter').hide();
          $('#buzz').show();
          $('#sentiment').hide();
          $('.navigation ul.clearfix:last li.buzz a').addClass('selected');
         },
       'height' : 380,
       'width' : 800
    });
    $('#graph-up .navigation li a').click( function(){
      $(this).parents('ul').find('a').removeClass('selected');
      $(this).addClass('selected');
      $('.graph-tab').children().hide();
      tab = $(this).attr('rel');
      $('#graph-up #' + tab).show();
      return false;
    });

});
