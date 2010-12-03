// Extension for easy URL variable access
$.extend({
  getId: function(){
    var current_params =window.location.href.split('/');
    var id = current_params[current_params.length-1];
    id = id.split('?')[0];
    return id;
  },

  test_url: function(value){ 
  return /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);
  },

  getLinkVars: function(where, link){
    var vars = [], hash;
    link = $(where).find(link);
    var hashes = $(link).attr('href').slice($(link).attr('href').indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },

  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },

  getUrlVar: function(name){
    return $.getUrlVars()[name];
  },

  getLinkVar: function(link, name){
    return $.getLinkVars(link)[name];
  }
});

//////////////////////////////////////////////////
// Hype It review/new
// Thomas Wright
/////////////////////////////////////////////////
jQuery(document).ready(function($)
{
  $("a.hype-item").livequery(function (){
      $(this).fancybox({
    'hideOnOverlayClick': false,
    'padding': 0,
    'autoDimensions': false,
    'width' : 665,
    'height': 700,
    'onClosed': function() { if (typeof($data) != 'undefined') {$.addItemToForm($data);$('#step_1').show();}},
    'onComplete': function() {     
        $('.options').show();
        $('#criteria_selects select').hide();
        $.fancybox.resize();
        $('#criteria_selects .option').bind('click', function() {
            var clicked = $(this);
            clicked.parents('.options').find('.option').removeClass('selected');
            clicked.addClass('selected');
            clicked.parents('.options').find('select').val(clicked.prevAll('.option').andSelf().length);

            return false;
        }).bind('mouseenter', function(e){
            var mouseEntered = $(this);
            mouseEntered.siblings('.option').andSelf().removeClass('highlighted');
            mouseEntered.prevAll('.option').andSelf().addClass('highlighted');
            return false;
            
        }).bind('mouseleave', function(e){
            var allOptions = $(this).siblings('.option').andSelf();
            var selected = allOptions.filter('.selected');
            allOptions.removeClass('highlighted');
            selected.prevAll('.option').andSelf().addClass('highlighted');
            return false;
        });
        
        $('#tags_pros_cons ul.pros li a').click(function() {

                var tag_option = $(this).text().trim();
                            var current_text = $('#pro_list').val();

                            if(current_text != '')
                            {
                                var new_text = current_text + ', ' + tag_option;
                            } else {
                                var new_text = tag_option;
                            }
                $('#pro_list').val(new_text);
            return false;
        });
      
        $('#tags_pros_cons ul.cons li a').click(function() {
                    var tag_option = $(this).text().trim();
                    var current_text = $('#con_list').val();

                    if(current_text != '')
                    {
                        var new_text = current_text + ', ' + tag_option;
                    } else {
                        var new_text = tag_option;
                    }
          $('#con_list').val(new_text);
          return false;
        });
      
          // this runs additional comments
        $('#additional-comments-link').live('click', function() {
          $('#additional-comments').toggle();        
          $.fancybox.resize();
          return false;
        });

        
        $('.more-show').live('click', function(){
          target = $(this).attr('rel');
          var visible = $('#'+ target).is(':visible');
          if (visible){
            $('#'+ target).hide();
            $(this).text('show  more'); 
          }
          else{
            $('#'+ target).show();
            $(this).text('show less');
          }
        });

        // Hype Form
        $('a.recommend_this').toggle(function() {
          $(this).html('Yes, worth the hype').addClass('selected');
          $('input#review_recommended').attr('checked', true);
        }, function() {
          $(this).html('Worth the Hype?').removeClass('selected');
          $('input#review_recommended').attr('checked', false);
        });
        $('a.top_ten_this').toggle(function() {
          $(this).html('Top Ten').addClass('selected');
        }, function() {
          $(this).html('Add To My Top Ten').removeClass('selected');
        });
        
        $('#review_first_word_list').keyup(function() {
          var charCount = $(this).val().length;
          var charsRemaining = 140 - charCount;
          var wordCountLabel = $('span.word-count');
          wordCountLabel.find('em').text(charsRemaining);
          wordCountLabel.removeClass('over-limit');
          if (charsRemaining < 0) {
            wordCountLabel.addClass('over-limit');
          }
        });
        
      
      }
      
    });  
    });  

    
    $('.add-to-faves').live('click', function() {
        $(this).hide();
        $(this).siblings('.wait').show();
        var item_id = $(this).children('a').attr('id');   
        $.ajax({
          type: "POST",
          url: "/items/" + item_id + "/favorite",
          data: {
            id: item_id,
            favorite: this.id == 'add'
          },
          success: function(data, status) {
            $(".favorites-wrapper").html(data);
          },
          error: function(xhr, status, ex) {
            $(this).siblings('.wait').hide();
          }
        });
          
          return false;
   });

    $('#twitter').live('click', function(){
     if ($(this).parents('li').hasClass('red_select')){
       $(this).parents('li').removeClass('red_select');
       $(this).html('<img src="../images/icons/twitter_20.gif" alt="Twitter_20">');
       $(this).siblings('#tweet_hype').val(false);
     }
     else {
       $(this).parents('li').addClass('red_select');
       $(this).html('<img src="../images/icons/twitter_selected.png" alt="Twitter_Selected">');
       $(this).siblings('#tweet_hype').val(true);
     }
     return false;
    });

  // auto open up hype-it form
  var hype_check = $.getUrlVar('hype_it');
  $.timer(300, function (timer) {
  if(hype_check == 'true'){
    $(".hype-it a.hype-item").trigger('click');
   }
    timer.stop();
  });

});
