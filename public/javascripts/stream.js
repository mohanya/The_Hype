jQuery(document).ready(function($) {

    //var toggle_fields_html = $('a.toggle_fields').html();
    $('.select-filter li a').click(function() {
      
      $(this).parent('li').siblings().children('a.selected').removeClass('selected');
      $(this).addClass('selected');
      
      target= $(this).attr('rel');
      $('#' + target).html("<img class='wait' src='/images/wait.gif'/>");
      var get_params = $.getUrlVars();
      var id = $(this).attr('id');

      if($(this).hasClass('a-global')){
       var scope = 'global';
      } 
      else {
        var scope = 'friends';
      }
      if (target != undefined ){
        var res= $.ajax({
        url: '/' + target,
        type: "GET",
         data: {scope: scope, id: id},
         success: function(html, status) {
          $('#' + target).html(html);
            if (target == 'activities'){
              if ($('.stream-li').length<15) {
                $('.stream-more').hide();
              }
              else {
              $('.stream-more').show();
              }
              $('.stream-more-new').hide();
              $('.stream-more#top').hide();
              $('.stream-more-new#top').hide();
              $('#live_count').hide();
            }
           if (target == "hyped_filter"){
             if (($('.slider-container li').length > 3) && !($('.slider-container').hasClass('carouseled'))){
               $('.slider-container').addClass('carouseled');
               $('.slider-container').jCarouselLite({
                 btnNext: ".next-button",
                 btnPrev: ".prev-button",
                 scroll: 3,
                 btnGo:
                   [".carousel-position-buttons .1",".carousel-position-buttons .2",".carousel-position-buttons .3",
                   ".carousel-position-buttons .4",".carousel-position-buttons .5"],
                 circular: false
               });
              }
           }
          return false;
        },
        error: function(xhr, status, ex) {
          
        }
       });
      }
      return false;
    });
    
    $("#the-stream .stream-more").click(function(){
      var offset = $("#the-stream .stream-more").attr('offset');
      $("#activities").html("<img class='wait' src='/images/wait.gif'/>");
      if ($(".a-global").hasClass("selected")) {
        var scope = 'global';
      } else {
        var scope = 'friends';
      }
        $.ajax({
        url: '/activities',
         data: {scope: scope, offset: offset},
         type: "GET",
         success: function(html, status) {
            $('#activities').html(html);
             if ($("#the-stream .stream-more").attr('offset') >=15) {
               $("#the-stream .stream-more-new").show();
               }
               if ($('.stream-li').length<15) {
                 $("#the-stream .stream-more").hide();
                 }
                 else {
                   $("#the-stream .stream-more").show();
                   }
            $("#the-stream .stream-more").attr("offset", parseInt(offset)+15);
            $("#the-stream .stream-more-new").attr("offset", (parseInt(offset)-15));
         }
        });
      return false;
    });
    
    $("#the-stream .stream-more-new").click(function(){
      var offset = $("#the-stream .stream-more-new").attr('offset');
      $("#activities").html("<img class='wait' src='/images/wait.gif'/>");
      if ($(".a-global").hasClass("selected")) {
        var scope = 'global';
      } else {
        var scope = 'friends';
      }
        $.ajax({
        url: '/activities',
         data: {scope: scope, offset: offset},
         type: "GET",
         success: function(html, status) {
            $('#activities').html(html);
           if ($("#the-stream .stream-more-new").attr("offset")<=0) {
             $("#the-stream .stream-more-new").hide()
           }
            if ($('.stream-li').length>=15) {
              $("#the-stream .stream-more").show();
              }
              else {
                $("#the-stream .stream-more").hide();
                }
            $("#the-stream .stream-more-new").attr("offset", parseInt(offset)-15);
           $("#the-stream .stream-more").attr("offset", (parseInt(offset)+15));
         }
        });
      return false;
    });
    
});
