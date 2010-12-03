String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ""); };
var slide_notify=1
function renderTrendChart(item_id) {
  $.getJSON("/items/" + item_id + "/trend.js", null, function(json) {
    var my_arr = new Array();
    line1=json;
    l_color='#0077cc';
    f_color='#0077cc';
    bg_color='ffffff';
    f_alpha=0.3;
    
    plot1 = $.jqplot('buzz2', [line1], {
        title:'The Buzz',
        grid:{background:bg_color},
        seriesDefaults:{color: l_color, fill: false, fillColor: f_color, fillAlpha: f_alpha, fillAndStroke: true},
        axesDefaults:{
          pad: 0,
          autoscale: true,
          tickDistribution: 'even',
          tickOptions:{mark: 'cross', markSize: 4}
        },
        axes:{
            xaxis:{
                renderer:$.jqplot.DateAxisRenderer,
                rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer}, 
                tickOptions:{
                  formatString:'%#m/%#d/%y', 
                  fontSize:'8pt', 
                  fontFamily:'Tahoma', 
                  angle:-15
                }             
            }, 
            yaxis: { 
              min: 0,
              base:10, 
              numberTicks: 6,
              tickDistribution: 'power',
              tickOptions:{formatString:'%d'} 
            }
        },
        highlighter: {sizeAdjust: 7.5},
        cursor:{
          zoom: true,
          showTooltip:false
        }
    });
    
    plot2 = $.jqplot('buzz3', [line1], {
        seriesDefaults:{color:l_color, neighborThreshold:0, fillColor: f_color, fillAlpha: f_alpha, fill: false, showMarker: false},
        grid:{background:bg_color},
        axesDefaults:{
          pad: 0,
          base:10, 
          showTicks: false,
          tickOptions:{show:false, showLable:false} 
        },
        axes:{
            xaxis:{
                renderer:$.jqplot.DateAxisRenderer,
                rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer}
            }, 
            yaxis: { 
              min: 0,
              base:10, 
              tickDistribution: 'power'
            }
        },
        cursor:{
          zoom: true,
          showTooltip:false,
          constrainZoomTo:'x'
        }
      });  
    $.jqplot.Cursor.zoomProxy(plot1, plot2);  
  });
}

var noChanges=true;
jQuery(document).ready(function($) {
  
  if(_myDummyBeforeUnload.allowBeforeUnload==1) {
    var eventToDo;
    
    $('#query').keypress(function() {
     if (noChanges==false) {
       eventToDo=window.location.href;
        $.get('/users/'+_myDummyBeforeUnload.userId+'/favorites/show_before_unload', {}, function(data){;
          $.fancybox(data,
          {
            autoScale: false,
            autoDimensions: false,
            width: 480,
            height: 226,
            padding: 0,
            'onStart' : function(){
              $('#fancybox-wrap').addClass('graph');
            },
            'onClosed' : function(){
              $('#fancybox-wrap').removeClass('graph');
              window.location.href=eventToDo
            },
            'onComplete': function() {
              $('#fancybox-close').hide();
            }
          });
          }, 'html');           
           return false;
       }
    });
    
    
    var showMe="#photo_user_info, #logo-image-link, .dropdown, #no_thanks, #cancel, #search_form_submit, .fb_logout, #admin_link"
    $(showMe).bind("click", function(e) {
      if ((this.id=="search_form_submit") && (noChanges==false)) {
       return false;
      }
      else if (this.id=="photo_user_info") {
        eventToDo='http://'+window.location.host+'/users/'+_myDummyBeforeUnload.userId;
      }
      else{eventToDo = e.target;}
      
      if (noChanges==false) {
        $.get('/users/'+_myDummyBeforeUnload.userId+'/favorites/show_before_unload', {}, function(data){;
          $.fancybox(data,
          {
            autoScale: false,
            autoDimensions: false,
            width: 480,
            height: 226,
            padding: 0,
            'onStart' : function(){
              $('#fancybox-wrap').addClass('graph');
            },
            'onClosed' : function(){
              $('#fancybox-wrap').removeClass('graph');
              window.location.href=eventToDo
            },
            'onComplete': function() {
              $('#fancybox-close').hide();
            }
          });
          }, 'html');  
           return false;
       }
    });
  }
  
$('.user_profile').livequery(function(){  
  if(_dummyObj.allowToOpen == 'true') {
    $('.index.favorites.tab#top_hypes').hide();
    $('.index.hypes.tab#reviews').hide();
    $('.friend-wrapper').hide();
    $('.index.hypes.tab#community').hide();
    $('#fancybox-close').hide();
    $.get('/users/private_user_follow_request?user_id='+_dummyObj.userId, {}, function(data){;
      $.fancybox(data,
      {
        autoScale: false,
        autoDimensions: false,
        width: 480,
        height: 240,
        padding: 0,
        'onStart' : function(){
          $('#fancybox-wrap').addClass('graph');
        },
        'onClosed' : function(){
           window.location.href ='http://'+window.location.host+'/';
          $('#fancybox-wrap').removeClass('graph');
        },
        'onComplete': function() {
          $('#fancybox-close').hide();
        }
      });
    }, 'html');
  }
});
  
  $("#green_cloud .close").click(function() {
      $('#green_cloud').slideUp(1000)
    document.cookie = "green_panel"+"="+0
   });

  $(".fake_facebook").live('click', function(){
    var link = $(this).attr('rel');
    var title = $(this).parents('li').attr('rel');
    window.open('http://www.facebook.com/sharer.php?u='+encodeURIComponent(link)+'&t='+encodeURIComponent(title),'sharer','toolbar=0,status=0,width=626,height=436');
    return false;
   });

  // Carousel for Most Hyped on Homepage 
  // Has to deal with situation when user has no Crowd and then click on The Crowd
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


  $('.next-button').click(function(){
    if( $('.carousel-position-buttons .active').hasClass('5') != true)
    {
      $('.carousel-position-buttons .active').removeClass('active').next().addClass('active');
    }
    
  });
  $('.prev-button').click(function(){
    if( $('.carousel-position-buttons .active').hasClass('1') != true)
    {
      $('.carousel-position-buttons .active').removeClass('active').prev().addClass('active');
    }
    
  });
  
    $('.delete_me input#export_my_own_data').click(function(e){
   e.preventDefault();
            $.get('/users/export_data_login_confirm', {}, function(data){;
            $.fancybox(data,
             {
                autoScale: false,
                autoDimensions: false,
                width: 480,
                height: 240,
                padding: 0,
                'onStart' : function(){
                  $('#fancybox-wrap').addClass('graph');
                },
                'onClosed' : function(){
                  $('#fancybox-wrap').removeClass('graph');
                }
             });
     }, 'html');
  }
  );
  
  
  

  $('.delete_me input#delete_button').click(function(e){
     if ($('input.check:checked').length < 1){
            e.preventDefault();
            $.get('/users/delete_error', {}, function(data){;
            $.fancybox(data,
             {
                autoScale: false,
                autoDimensions: false,
                width: 480,
                height: 240,
                padding: 0,
                'onStart' : function(){
                  $('#fancybox-wrap').addClass('graph');
                },
                'onClosed' : function(){
                  $('#fancybox-wrap').removeClass('graph');
                }
             });
     }, 'html');
     }else{
			e.preventDefault();
         $.get('/users/delete_confirm', {}, function(data){;
         $.fancybox(data,
          {
             autoScale: false,
             autoDimensions: false,
             width: 480,
             height: 240,
             padding: 0,
             'onStart' : function(){
               $('#fancybox-wrap').addClass('graph');
             },
             'onClosed' : function(){
               $('#fancybox-wrap').removeClass('graph');
             }
          });
  }, 'html');
     }
   return false;
  });

  
  $('textarea.character_count').live('keyup', function(){   
      var length = $(this).val().length;  
      if (parseInt(length) != "NaN")
        $(this).parents().find('.num_characters').html( 140 - parseInt(length) );  
  });
  
  
  //vanity url validation for username in signup

  $('#user_login').blur(function(){
    if($('#user_login').next().length==0)
    {   
      $('<span id="vanity_url" style="font-size:11px"></span>').insertAfter($('#user_login'));
      vanityValidation($('#user_login').val());
    }
    else
    {
      vanityValidation($('#user_login').val());
    }
  });
  
  // Setup example text for inputs
  $('textarea.example').livequery(function() {
    $(this).example(function() {
      return $(this).attr('title');
    }, {className: 'blur'});
  });
  
  
  // Set textarea's to use the elastic feature
  $('textarea.elastic').livequery(function() {
    $(this).elastic();
  });

  // I'm on the outside
  hostname = window.location.hostname
  $("a[href^=http]")
    .not("a[href*='" + hostname + "']")
    .addClass('link external')
    .attr('target', '_blank');

 
  $('.fb_logout').click(function() {
    FB.Connect.logoutAndRedirect("/logout");
  });

  $('#user_passwd').change(function() {    
    $('#user_passwd_confirm').slideToggle(); 
    if((slide_notify%2)==1)
    {
      $('#user_password_confirmation').focus();   
    }
    else
    {
      $('#user_email').focus();   
    }
    slide_notify=slide_notify+1;
  });

  $("a.fancybox").livequery(function(){
      $(this).fancybox({
    'autoDimensions': false,
     width: 660,
     height: 320,
     titleShow: false
    });
  });


  // http://blog.dansnetwork.com/2008/11/01/javascript-iso8601rfc3339-date-parser/
  //
  Date.prototype.setISO8601 = function(dString) {
    var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;

    if (dString.toString().match(new RegExp(regexp))) {
      var d = dString.match(new RegExp(regexp));
      var offset = 0;

      this.setUTCDate(1);
      this.setUTCFullYear(parseInt(d[1],10));
      this.setUTCMonth(parseInt(d[3],10) - 1);
      this.setUTCDate(parseInt(d[5],10));
      this.setUTCHours(parseInt(d[7],10));
      this.setUTCMinutes(parseInt(d[9],10));
      this.setUTCSeconds(parseInt(d[11],10));
      if (d[12])
        this.setUTCMilliseconds(parseFloat(d[12]) * 1000);
      else
        this.setUTCMilliseconds(0);

      if (d[13] != 'Z') {
        offset = (d[15] * 60) + parseInt(d[17],10);
        offset *= ((d[14] == '-') ? -1 : 1);
        this.setTime(this.getTime() - offset * 60 * 1000);
      }
    }
    else {
      this.setTime(Date.parse(dString));
    }

    return this;
  };
  
  
  $('#add_item_form input#query').example('Search to Add an Item');

  $('a.toggle_fields').toggle(function() {
    $('.search_forms').hide();
    $('.add_item_form').show();
    $('a.toggle_fields').html("Cancel");
  }, function() {
    $('.add_item_form').hide();
    $('.search_forms').show();
    $(this).html(toggle_fields_html);
  });
  
  $('.header .tabs a').click(function() {
    $('.header li.selected').removeClass('selected');
    $(this).parent('li').addClass('selected');
    return false;
  });
  
  $('.navigation .tabs .navigation_holder a').click(function() {
    $('.header li.selected').removeClass('selected');
    $(this).parent('li').addClass('selected');
    return false;
  });
  
  // Tabs
  var item_content_tabContainers = $('.item_content .tabs .navigation_holder  > div');
  var item_content_tabLinks = $('.item_content .navigation a');
  
  $('.item_content .tabs .navigation_holder > div').hide().filter(':first').show();
  //
  item_content_tabLinks.click(function() {
    item_content_tabContainers.hide();
    item_content_tabContainers.filter(this.hash).show();
    item_content_tabLinks.removeClass('selected');
    $(this).addClass('selected');
    return false;
  });
  $('.item_content .tabs .navigation_holder > div').wrapInner('<div class="padding"></div>');
  item_content_tabLinks.filter(':first').click();
  
  // Tabs
  var page_body_tabContainers = $('.page_body .tabs > .tab');
  var page_body_tabLinks = $('.page_body .navigation a');
  
  page_body_tabContainers.hide().filter(':first').show();
  //
  $('.page_body .navigation a').click(function () {
     page_body_tabContainers.hide();
         page_body_tabContainers.filter(this.hash).show();
         page_body_tabLinks.removeClass('selected');
         $(this).addClass('selected');
         var page_body_headers = $('.page_body .tabs .navigation_holder > h1');
         page_body_headers.hide();
         page_body_headers.filter(this.hash + '_head').show();
         var page_body_subheaders = $('.page_body .tabs > h3');
         page_body_subheaders.hide();
         page_body_subheaders.filter(this.hash + '_header').show();
         if ($(this).parents('li').hasClass('details')){
           if (($("#all_images li").length > 4) && !($("#all_images").hasClass('carousel'))) {
              $("#all_images").addClass('carousel');
              $("#additional-images .nav").show();
              $('#all_images').jCarouselLite({
                vertical: false,
                scroll: 4,
                visible: 4,
                start: 0,
                circular: true,
                btnNext: "#additional-images .next",
                btnPrev: "#additional-images .prev"
               });
             }
         }
         return false;
  });
  page_body_tabLinks.filter(':first').click();

  $('.user_profile .header .container ul li a').click(function() {
    $('.navigation a').removeClass('selected')
    if (this.id=="followers" || this.id=="following") {
      $('#community_nav').addClass('selected')
      
      $('#top_hypes_head').hide();
      $('#reviews_head').hide();
      $('#community_head').show();
      
      $('#top_hypes_header').hide();
      $('#reviews_header').hide();
      $('#community_header').show();
      
      $('#top_hypes').hide();
      $('#reviews').hide();
      $('#community').show();
      
      var id = _currentUserProfile.id;
      
      if (this.id=="followers") {
          $('.select-filter a:last').removeClass('selected')
          $('.select-filter a:first').addClass('selected')
          $('#friendships').html("<img class='wait' src='/images/wait.gif'/>");
          $.get("/friendships" , {id: id, friends_page: 1, scope: 'global'}, function(data)
          {
          $('#friendships').html(data);
          },
          'html'
          );
        }
        else {
          $('.select-filter a:first').removeClass('selected')
          $('.select-filter a:last').addClass('selected')
          $('#friendships').html("<img class='wait' src='/images/wait.gif'/>");
          $.get("/friendships" , {id: id, friends_page: 1, scope: 'friends'}, function(data)
          {
          $('#friendships').html(data);
          },
          'html'
          );
          }
      }
      
    else {
      $('#reviews_nav').addClass('selected')
      
      $('#top_hypes_head').hide();
      $('#reviews_head').show();
      $('#community_head').hide();
      
      $('#top_hypes_header').hide();
      $('#reviews_header').show();
      $('#community_header').hide();
      
      $('#top_hypes').hide();
      $('#reviews').show();
      $('#community').hide();
      }
  });
  
  
  
  
  // Setup the overlay_panel
  var overlay_panels = $('.item').find('.overlay_panel');
  $('.rating').toggle(function() {
    overlay_panels.hide();
    $(this).parents('.item').find('.overlay_panel').show();
  }, function() {
    $(this).parents('.item').find('.overlay_panel').hide();
  });

  $('.Item-show .tabable').click(function(){
    tab = $(this).attr('rel'); 
    $('.page_body .navigation a[href$="#' + tab + '"] ').click();
    $.scrollTo('.navigation_holder', 300);
    return false;
  });

    //friendships
    $('.add-to-friends').live('click', function() {
      var friend_id = $(this).children('a').attr('rel');
      var follow_action = $(this).attr('id');
      $(this).parent().children('.wait').show();
      $(this).hide();
      var follow_selector_message = 'a[rel^=' +friend_id+'] img';
     $(follow_selector_message).parents('#new-message-button').hide();
      $.ajax({
        type: "POST",
        url: "/users/" + friend_id + "/follow",
        data: {
          id: friend_id,
          follow: this.id == 'add'
        },
        success: function(html, status) {
          $('div.wait').hide();
          follow_selector = 'a[rel^=' +friend_id+'] img';
          if (follow_action == 'add') {
            $(follow_selector).parents('.add-to-friends#remove').show();
            $(follow_selector).parents('#new-message-button').show();
            }
          else if (follow_action == 'remove') {
            $(follow_selector).parents('#new-message-button').hide();
            $(follow_selector).parents('.add-to-friends#add').show();
            }
        },
        error: function(xhr, status, ex) {
          $('div.wait').hide();
        }
      });
      return false;
    });


  $('.submenu_link').bind('click', function() {
    var submenu = $(this).siblings('.submenu');
    var submenuLink = $(this);
    submenu.toggle(function() {
      submenuLink.addClass('highlighted');
      $(document).bind('click.submenu', function(e) {
        submenu.hide();
        submenuLink.removeClass('highlighted');
        $(this).unbind('click.submenu')
      });

    });
    
    return false;

    //$.timer(3000, function (timer) {
      //$('.submenu').mouseout(function() {
        //$(this).toggle(); 
      //});
      // timer.stop();
    //});


  }).bind('mouseenter', function(){
    var submenuLink = $(this);
    submenuLink.addClass('highlighted');
    
    return false;
  }).bind('mouseleave', function(){
    var submenuLink = $(this);
    if ($(this).siblings('.submenu').is(':hidden')) {
      submenuLink.removeClass('highlighted');
    }
    
    return false;
  });
  
  $('#browse-most-recent').bind('click', function() {
    var mostRecent = $(this)
    $.ajax({
      type: 'GET',
      url: mostRecent.attr('href'),
      beforeSend: function(){
        $('#index-ajax-spinner').css('display','block');
        },
      success: function(data) {
        $('.sorting ul li a').attr('class','button');
        mostRecent.attr('class','button selected');
        $('#browse').html(data);
      },
      complete: function(){
        $('#index-ajax-spinner').css('display','none');
        }
    })
    return false;
  });
  
  $('#browse-top-rated').bind('click', function() {
    var topRate = $(this)
    $.ajax({
      type: 'GET',
      url: topRate.attr('href'),
      beforeSend: function(){
        $('#index-ajax-spinner').css('display','block');
        },
      success: function(data) {
        $('.sorting ul li a').attr('class','button');
        topRate.attr('class','button selected');
        $('#browse').html(data);
      },
      complete: function(){
        $('#index-ajax-spinner').css('display','none');
        }
    })
    return false
  });
  
  $('#browse-most-active').bind('click', function() {
    var mostActive = $(this)
    $.ajax({
      type: 'GET',
      url: mostActive.attr('href'),
      beforeSend: function(){
        $('#index-ajax-spinner').css('display','block');
        },
      success: function(data) {
        $('.sorting ul li a').attr('class','button');
        mostActive.attr('class','button selected');
        $('#browse').html(data);
      },
      complete: function(){
        $('#index-ajax-spinner').css('display','none');
        }
    })
    return false
  });
  
  $('#browse-most-hyped').bind('click', function() {
    var mostHyped = $(this)
    $.ajax({
      type: 'GET',
      url: mostHyped.attr('href'),
      beforeSend: function(){
        $('#index-ajax-spinner').css('display','block');
        },
      success: function(data) {
        $('.sorting ul li a').attr('class','button');
        mostHyped.attr('class','button selected');
        $('#browse').html(data);
      },
      complete: function(){
        $('#index-ajax-spinner').css('display','none');
        }
    })
    return false
  });

  

});

jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} 
});

jQuery.query = function(s) {
  var r = {};
  if (s) {
    var q = s.substring(s.indexOf('?') + 1); // remove everything up to the ?
    q = q.replace(/\&$/, ''); // remove the trailing &
    jQuery.each(q.split('&'), function() {
        var splitted = this.split('=');
        var key = splitted[0];
        var val = splitted[1];
        // convert numbers
        if (/^[0-9.]+$/.test(val)) val = parseFloat(val);
        // convert booleans
        if (val == 'true') val = true;
        if (val == 'false') val = false;
         // ignore empty values
        if (typeof val == 'number' || typeof val == 'boolean' || val.length > 0) r[key] = val;
        });
  }
  return r;
};

var _myOwnObject = {
    allow: 1
  }
  
function blockButton()  {
  _myOwnObject.allow = 2;
  return true;
}

function closeForCsv()
{
  $("#errorExplanation").hide()
  $.fancybox.close();
}

function profilePrivate(chck) {
  if (chck == 0) {
    $('#private_radio').html("<input type='radio' value='true' onclick='profilePrivate(1);' name='user[profile_attributes][private]' id='user_profile_attributes_private_false' class='user_profile_attributes_private_true'>");
    }
    else {
       $('#private_radio').html("<input type='radio' value='true' onclick='profilePrivate(0);' name='user[profile_attributes][private]' id='user_profile_attributes_private_false' class='user_profile_attributes_private_true' checked='checked'>");
      }
  }
  
var _myDummyBeforeUnload= {
     allowBeforeUnload: 0,
     userId: null,
     alphaPopupSession: 0
 }  
 
 var _currentUserProfile={
    id:false
}

function vanityValidation(value)
{  
  $.get('/users/vanity_validation', {'username':value}, function(data){    
    if(data=="true")
    {
      $("#vanity_url").html(" username is not available").css('color','red');
    }
    else
    {      
      $("#vanity_url").html(" username is available!").css('color','green');    
      /*if (value.length<3)
      {
       $("#vanity_url").html(" username is min 3 characters").css('color','red');
      }
      else
      {  
      $("#vanity_url").html(" username is available!").css('color','green');    
      } */
    }
  });
}
