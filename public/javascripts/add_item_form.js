var video_count=1;
var embed_total=new Array();
var thumb_total=new Array();
var thumb_arr=new Array();
var embed_arr=new Array();
jQuery(document).ready(function($){
  
  $('#cancel').click(function(e){
      $.fancybox.close();
      return false;
  });

  $("#first_box dt.item-name").live('click', function() {
    $("#item_short_description").val(jQuery.trim($(this).parents(".item-suggestion").find("dd.description").text()));
    $("#item_source_id").val($(this).parents(".item-suggestion").find(".source_id").text());
    $("#item_artist_name").val($(this).parents(".item-suggestion").find(".artist_name").text());
    $("#release_year").val($(this).parents(".item-suggestion").find(".release_year").text());
    $('h1#desc').addClass('filled');
  });
  
  $("#location_data dt.item-name").live('click', function() {
    $("#item_short_description").val(jQuery.trim($(this).parents(".item-suggestion").find("dd.description").text()));
    $("#item_source_id").val($(this).parents(".item-suggestion").find(".source_id").text());
    $("#item_artist_name").val($(this).parents(".item-suggestion").find(".artist_name").text());
    $("#release_year").val($(this).parents(".item-suggestion").find(".release_year").text());
    $('h1#desc').addClass('filled');
  });

  $("#secondary_source dt.item-name").live('click', function(){
    $("#source_name").val('wiki');
  });

  $("#item_short_description").live('change', function(){
    $("#source_name").val('');
    if ($(this).val() == ''){
      $('h1#desc').removeClass('filled');
    } 
   else  {
      $('h1#desc').addClass('filled');
   }
  });

  $('#fancybox-inner ul.select-filter a').live('click', function(){
    $('ul.select-filter a').removeClass('selected');
    $(this).addClass('selected');
    $('.tabbed').hide();
    $('#' + $(this).attr('rel')).show(); 
  });
   

  $('a[rel*=fancybox]').fancybox({
    'autoScale': true,
    'padding': 0,
    'autoDimensions': false,
    'titleShow' : false,
    'hideOnOverlayClick' : false,
    'hideOnContentClick' : false,
    'width' : 810,
    'height': 500,
    'onComplete': function(){ 
	// This is for google image search.
	// This value gets incremented each search and then passed to searches/image
	var start_count = 0;
	$('#item_root_category').change( function(){
          $('#sub_categories_header').hide();
	  $('#item_category_id').val($(this).attr('value'));
	  $.get("/items/sub_categories/" + $(this).attr('value'), '', function(data){
              if (data.trim() != ''){
                $('#sub_categories').html(data);
                $('#sub_categories_header').show();
                $('#fancybox-inner').css('height', '520px');
                $('#fancybox-wrap').css('height', '520px');
                }
              else{
	        $('#sub_categories_header').hide();
                $('#fancybox-inner').css('height', '500px');
                $('#fancybox-wrap').css('height', '500px');
              }
           },'html');
        }); // itemCategory end
	
	$('.button').live("click", function(){
	  $(this).attr("value");
	  $('#sub_categories a.selected').removeClass('selected');
          $(this).addClass('selected');
	  $('#item_category_id').val($(this).attr('id'));
	}); // button click end
	
        function search_api(item_name,search_source, div_target){
          div_target.html("<img class='wait_spinner " + div_target.attr("id") + "_wait' src='/images/wait.gif'/>");
          $.get("/search_api", {query: item_name, source: search_source}, function(data){
            $("img." + div_target.attr("id") + "_wait").hide();
            div_target.append(data);
          },
          'html'
         ); 
        } //search api end

	function search_images(query, category_id, start, div_target){
          div_target.append("<img class='" + div_target.attr("id") + "_wait' src='/images/wait.gif' />");
          $.get("/searches/image", {query: query, category_id: category_id, start: start}, function(data){
            div_target.append(data);
            $("img." + div_target.attr("id") + "_wait").remove();
          },
          'html'
          );
        } //search images end
        
        $(".new_item").formwizard({ 
          //form wizard settings
          historyEnabled : false, 
          formPluginEnabled: true,
          focusFirstInput: true,
          validationEnabled : true,
          textNext : '',
	  textSubmit : '',
          //submitStepClass : '.submit_step' //default
          afterNext: function(args){
            //video selection
            
            if(args.currentStep== "video_selection")
            {              
              $.get('/users/video_selection', {'keyword':"phone"}, function(data){
                var video_total=new Array();
                video_total=data.split("::splitter::"); 
                embed_total=video_total[0].split("::");
                thumb_total=video_total[1].split("::"); 
                for(var count=0;count<6;count++)
                {                  
                  embed_arr[count]=embed_total[count];
                  thumb_arr[count]=thumb_total[count];
                }
                videoSearchResult(embed_arr,thumb_arr);
              });              
            }
            
            
            if (args.currentStep == "description") {
              $(".only_first_step").hide();              
              category =  $('#item_category_id').val();
              if ($("#prev_type").val() != category){
	        $.get("/items/additional_item_data/", {cid: category}, function(data){
                    $("#prev_type").val(category);
                    if (data.trim() != ''){
                      $('#fancybox-wrap #first_box').css('width', '210px');
                      $('#fancybox-wrap .second').addClass('third').removeClass('second');
                      $('#fancybox-wrap #additional_data_fields').html(data).show();
                      }
                    else{
                      $('#fancybox-wrap #first_box').css('width', '270px');
                      $('#fancybox-wrap .third').addClass('second').removeClass('third');
                      $('#fancybox-wrap #additional_data_fields').html('').hide();
                    }
	          },
	        'html'
	     ); //addditional data end
             }
         search_api($("#item_name").val(), $("#item_category_id").val(), $('#primary_source'));
	 search_api($("#item_name").val(), 'wikipedia', $('#secondary_source'));

         $("#edit_keyword_link").bind('click', function(){
             $("#edit_keyword_link").hide();
             $(".keywords_form").show();
          });

         $("#close_keyword").bind('click', function(){
             $("#edit_keyword_link").show();
             $(".keywords_form").hide();
          });

         $("#search_new_keyword").bind('click', function(){
           search_api($("#new_keyword").val(), $("#item_category_id").val(), $('#primary_source'));
	   search_api($("#new_keyword").val(), 'wikipedia', $('#secondary_source'));
           $('.dynamic_time').hide();
          });
        }
						
        if (args.currentStep == "image_selection"){
           $(".only_first_step").hide();
           //////////////////////////////////////////////////////////////
           // Google Image Search Section
           //////////////////////////////////////////////////////////////
           search_term = $('#item_name').val();
           
           if ($("#item_category_id").val().match(/music/)){                  
             artist_name = $("#item_artist_name").val();
             if (artist_name != search_term){
               search_term = search_term + " " + artist_name;
             }
           }
           
           if ($("#item_category_id").val().match(/movie/i)){
             release_year = $("#release_year").val();
             search_term = search_term + " " + release_year;
           }
           //LoadGoogleImages(search_term);
           search_images(search_term, $("#item_category_id").val(), start_count, $('#image_search_results'));
           start_count++;
           // Load more images
           $('#load_more_images').bind('click', function(){
           search_images(search_term, $("#item_category_id").val(), start_count, $('#image_search_results'));
           start_count++;
           return false;
           });
          
          // On double click make it the primary.
            $('.search_image').live("dblclick", function(){
                    var parent_id = $(this).parents('.google_image_wrap').attr('id');
                    $('img.selected_primary').removeClass('selected_primary');
                    $(this).addClass('selected_primary');
                    $('img.current_image').attr('src', this.src);
                    $('#primary_image').val(this.alt);
                    $(this).removeClass('selected_image').siblings('input:checkbox').attr('checked', false);
                    $("#secondary_images_display img#img_" +parent_id).remove();
           return false;
             });
              //load more videos
              $("#load_more_videos").click(function(){
                video_count=video_count+1;
                var sub_count=0;
                for(var count=(video_count*6)-6;count<(video_count*6)-1;count++)
                {                  
                  embed_arr[sub_count]=embed_total[count];
                  thumb_arr[sub_count]=thumb_total[count];
                  sub_count=sub_count+1;
                }
                videoSearchResult(embed_arr,thumb_arr);
              });

             // 
             // we make image added by user behave just like google search images
             $("#add_from_url").live('click', function(){
               var url = jQuery.trim($("#new_image_url").val());
               if (url != ''){
                 if ($.test_url(url) == true){
                    $('#custom_image .error').hide();
                    $("#new_image_url").val('');
                    var id = 'url_' + Math.floor(Math.random()*201);
                    html =  '<div class="google_image_wrap" id="'+ id + '"><img class="search_image" alt="' +
                            url +'" src="' + url +'"/>' + '<input type="checkbox" value="' + url +  
                            '" name="image_checkbox[' + id + ']" id="image_checkbox_' + id + '"></div>'
                    $("#image_url_displays").append(html);
                  }
                  else{
                    $('#custom_image .error').show();
                  }
               }
                return false;
             });
           // On single click toggle select
               $('.search_image').live("click", function(){
                  var parent_id = $(this).parents('.google_image_wrap').attr('id');
                  if($(this).hasClass('selected_image')){
                    $(this).removeClass('selected_image');
                    $(this).siblings('input:checkbox').attr('checked', false);
                    $("#secondary_images_display img#img_" +parent_id).remove();
                  }
                  else{
                    if(!$(this).hasClass('selected_primary')){
                      $(this).addClass('selected_image');
                      $(this).siblings('input:checkbox').attr('checked', true);
                      if ($("#secondary_images_display img#img_" + parent_id ).length < 1){
                        $("#secondary_images_display").append("<img class='secondary' id='img_"+ parent_id +"' src='"+  this.src + "' alt='"+ this.alt +"' />");
                      }
                    }
                  }
                return false;
                });
             } 
           }, 
           afterBack: function(args){
            if (args.currentStep == "name") {
              $(".only_first_step").show();
            }
          }   
         },
         {
           errorPlacement: function(label, element) {
              $('.extra').show();
              label.insertAfter( element );
              $('label.error').siblings('.extra').hide();
           },
           success: function(label){
                  $(label).siblings('.extra').show();
                  $(label).remove();

          }

         },
         // validation end
         {
         // form plugin settings
         dataType: 'json',
         beforeSubmit: function(){
             $("#submit_wait_image img.wait").show();
             $("#next-button").hide();
             $("#back_button").hide();
         },
         success: function(data, status)
         {
            $(".new_item").hide();
            $("#hype-it").show();//.html(data.toString());
            $('#fancybox-inner').css('height', '260px');
            $('#fancybox-wrap').css('height', '260px');
            if ($('body#users_favorites').length == 1) {
              $data = data;
              var url = "http://" + window.location.host +  "/items/" + data.id + "?hype_it=true'" + ">Hype It!</a>";
              $(".two-options-holder").append("<a class='hype-item' href='" + url);
	      $(".two-options-holder").append("<a class='show-item' href='javascript:;'>No Thanks Just Add It</a>");
              $('.show-item').click(function() {
                $.addItemToForm($data);
                $.fancybox.close();
              });
            } 
            else {
              var url = "http://" + window.location.host +  "/items/" + data.id + "?hype_it=true'" + ">Hype It!</a>";
              $(".two-options-holder").append("<a class='hype-items' href='" + url);
              var show_url = 'http://' + window.location.host + "/items/" + data.id;
	      $(".two-options-holder").append("<a class='show-item' href=" + show_url + ">No Thanks Just Add It</a>");
            }
         return false;
       }
     }
     // success end
   ); 
   // form wizard end
  } //onComplete end
  }); //fancybox end
}); //jQuery end
function videoSearchResult(embed,thumb)
{
  $("#video_search_results").append("<div id=result_"+video_count+"></div>");  
  for(var count=0;count<6;count++)
  {    
    var element=$("<img src="+thumb[count]+" id="+embed[count]+"/>");    
    element.click(function(){
      var url=this.id;
      var embed_video=$("<embed width='200px' height='200px' name='plugin' src='"+url+"' type='application/x-shockwave-flash'>");      
      $("#primary_video_display").html(embed_video);
    });
    $("#result_"+video_count).append(element);   
  }
}

