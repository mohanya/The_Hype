jQuery(document).ready(function($){
  $('a.change').live('click', function(){
    $('.dynamic_location').toggle();
    return false;
  });
  
  $("#google_local_results dt.item-name").live('click', function() {
    var arr = ['source_id','address', 'city', 'state', 'country', 'zip'];
    var empty = 0;
    for( i=0; i < arr.length; i++){
      var what = arr[i];
      var text = jQuery.trim($(this).siblings('.'+ what).text());
      if (text !=''){
        $(".static_" + what).text(text).show();
        $("#additional_" + what).val(text);
        }
      else {
          empty = empty + 1;
      }
    }
    if ((empty == 4) && $('#location_data .empty').is(':visible')){
        $('h1#loc').removeClass('filled');
     }
    else{
      $('h1#loc').addClass('filled');
      $('#location_data .empty').hide();
    }
  });

  $("#primary_source dt.item-name").live('click', function() {
    var arr = ['source_id','address', 'city', 'state', 'country', 'zip'];
    var empty = 0;
    for( i=0; i < arr.length; i++){
      var what = arr[i];
      var text = jQuery.trim($(this).siblings('.'+ what).text());
      if (text !=''){
        $(".static_" + what).text(text).show();
        $("#additional_" + what).val(text);
        }
      else {
          empty = empty + 1;
      }
    }
    if ((empty == 4) && $('#location_data .empty').is(':visible')){
        $('h1#loc').removeClass('filled');
     }
    else{
      $('h1#loc').addClass('filled');
      $('#location_data .empty').hide();
    }
  });
  
  $('.find_place_additional_info').live('click', function(){
    search_place($("#full_address").val(), 'place' , $('#google_local_results'));
  });

 function search_place(item_name,search_source, div_target){
     div_target.html("<img class='" + div_target.attr("id") + "_wait' src='/images/wait.gif'/>").show();
     $.get("/search_api", {type: 'place_only', query: item_name, source: search_source}, function(data){
       div_target.append(data);
       $("img." + div_target.attr("id") + "_wait").remove();
       },
    'html'
     );
 } //search api end

});
