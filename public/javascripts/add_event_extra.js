jQuery(document).ready(function($){

    $("#additional_start_date").AnyTime_picker( { format: "%M, %e %z", firstDOW: 1, labelTitle : 'Select Start Date' });
    $("#additional_start_time").AnyTime_picker(   { format: "%h:%i %p", labelTitle : 'Select Start Time' });
    $("#additional_end_date").AnyTime_picker( { format: "%M, %e %z", firstDOW: 1, labelTitle : 'Select End Date' });
    $("#additional_end_time").AnyTime_picker(   { format: "%h:%i %p", labelTitle : 'Select End Time' });

    $("#additional_start_date").live('change', function(){
       $('#time_data .empty').hide();
       $(".static_start_date").text($(this).val());
       $('h1#dati').addClass('filled');
    });

    $("#additional_start_time").live('change', function(){
       $('#time_data .empty').hide();
       var value = $(this).val(); 
       if (value == '00:00'){
          value = '';
       }
       $(".static_start_time").text(value);
       $('h1#dati').addClass('filled');
    });
    $("#additional_end_date").live('change', function(){
       $('#time_data .empty').hide();
       $('.dated').show();
       $(".static_end_date").text($(this).val()).show();
       $('h1#dati').addClass('filled');
    });
    $("#additional_end_time").live('change', function(){
       $('#time_data .empty').hide();
       var value = $(this).val(); 
       if (value == '00:00'){
          value = '';
          $('.timed').hide();
       }
       else{
          $('.timed').show();
       }
       $(".static_end_time").text(value).show();
       $('h1#dati').addClass('filled');
    });


  $('a.change').live('click', function(){
    $('.dynamic_location').toggle();
    return false;
  });

 $('a.end_time_handler').live('click', function(){
    if ($('.dynamic_end_date .time_input').is(':visible')) {
         $('.dynamic_end_date .time_input').hide();
         $(".static_end_time").hide();
         $('a.end_time_handler').addClass('unchecked');
         $('.timed').hide();
         $("#additional_end_time").val('');
     }
     else {
         $(".static_end_time").show();
         $('#additional_end_time').val($(".static_end_time").text());
         $('a.end_time_handler').removeClass('unchecked');
         if ($(".static_end_time").text() != ''){
           $('.timed').show();
         }
         $('.dynamic_end_date .time_input').show();
     }
    return false
 });

 $('a.end_date_handler').live('click', function(){
    if ($('.dynamic_end_date .date_input').is(':visible')) {
         $('.dynamic_end_date .date_input').hide();
         $('a.end_date_handler').addClass('unchecked');
         $(".static_end_date").hide();
         $('.dated').hide();
         $("#additional_end_date").val('');
     }
     else {
         $(".static_end_date").show();
         $('#additional_end_date').val($(".static_end_date").text());
         $('a.end_date_handler').removeClass('unchecked');
         if ($(".static_end_date").text() != ''){
           $('.dated').show();
         }
         $('.dynamic_end_date .date_input').show();
     }
     return false;
 });

 $('a.end_date_something').live('click', function(){
    $('.dynamic_end_date').toggle();
    return false
 });

 $('a.change_time').live('click', function(){
    if ($('#dynamic_time').is(':hidden')){
      $('#dynamic_time').show();
    var arr = ['start_date', 'start_time', 'end_date', 'end_time'];
    for( i=0; i < arr.length; i++){
      var what = arr[i];
      if (jQuery.trim($(".static_" + what).val()) !=''){
        $("#additional_" + what).val($(".static_" + what).text());
        }
       }
    }
    else { 
      $('#dynamic_time').hide();
    }

  });

  $("dt.item-name").live('click', function() {
    var arr = ['address', 'city', 'state', 'country', 'zip'];
    var empty = 0;
    for( i=0; i < arr.length; i++){
      var what = arr[i];
      var text = jQuery.trim($(this).siblings('.'+ what).text());
      $(".static_" + what).text(text).show();
      $("#additional_" + what).val(text);
      if (text == ''){
         empty = empty + 1;
       }
    }
    if (empty == 4){
        $('h1#loc').removeClass('filled');
    }
    else{
        $('h1#loc').addClass('filled');
        $('#location_data .empty').hide();
    }
    var arr = ['start_date', 'start_time', 'end_date', 'end_time'];
    for( i=0; i < arr.length; i++){
      var what = arr[i];
      var text = jQuery.trim($(this).siblings('.'+ what).text());
      if (text !=''){
        $('#time_data .empty').hide();
        $(".static_" + what).text(text).show();
        $("#additional_" + what).val(text);
        $('h1#dati').addClass('filled');
        if (what == 'end_date'){
          $('.dated').show();
          $('a.end_date_handler').removeClass('unchecked');
        }
        if (what == 'end_time'){
          $('.timed').show();
          $('a.end_time_handler').removeClass('unchecked');
        }
       }
     }
    return true;
  });

  $('.find_event_additional_info').live('click', function(){
    search_event_place($("#full_address").val(), 'google_local' , $('#google_local_results'));
  });

  $("#google_local_results dt.item-name").live('click', function() {
       $("#item_source_id").val('');
  });

 function search_event_place(item_name,search_source, div_target){
     div_target.html("<img class='" + div_target.attr("id") + "_wait' src='/images/wait.gif'/>").show();
     $.get("/search_api", {type: 'event_only', query: item_name, source: search_source}, function(data){
       div_target.append(data);
       $("img." + div_target.attr("id") + "_wait").remove();
       },
    'html'
     );
 } //search api end
}); 
