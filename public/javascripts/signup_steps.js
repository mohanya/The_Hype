// js code for signup process

//attach fancybox to all categories in step 2

$.extend({
  addItemToForm:  function(data) {
                    //inject item data into the form
                    noChanges=false;
                    $('#'+cat_id+'_field').attr({value: data["id"]});
                    $('#'+cat_id+'_field').attr({name: sub_id + '_field'});
                    if (sub_id=='tv') {
                    sub_id=sub_id.toUpperCase()
                    }
                    $('#'+cat_id+'_item_name').html("<div class='text'>" + $("#mini_search").val() + "</div>" + "<div class='bottom'>" + sub_id + "</div>");
                    $('#'+cat_id+'_item_label').hide();
                    $('#'+cat_id+'_add_button').hide();
                    $(".edit a[ref=" + cat_id + "].add").show();
                    $(".category-name").text(data["category"]);


                    var img = $('#'+cat_id+'_item_image');
                    img.attr({src: data["image_path"]});
                    img.show();

                    var rating = $('#'+cat_id+'_item_rating');
                    if (data['rating'] > 0.0) {
                      rating.html(data["rating"]).show();
                    } else {
                      rating.hide();
                    }

                    $('#' + cat_id + '_remove').show();
                    $('#' + cat_id + '_item_name').show();

                    return false;
                  }
});

jQuery(document).ready(function() {
  
  if (_myDummyBeforeUnload.alphaPopupSession==1) {
    $('.start_hyping').livequery(function(){  
      $('.index.favorites.tab#top_hypes').hide();
      $('.index.hypes.tab#reviews').hide();
      $('.friend-wrapper').hide();
      $('.index.hypes.tab#community').hide();
      $('#fancybox-close').hide();
      $.get('/users/alpha_phase', {}, function(data){;
        $.fancybox(data,
        {
          autoScale: false,
          autoDimensions: false,
          width: 776,
          height: 584,
          padding: 0,
          'onStart' : function(){
            $('#fancybox-wrap').addClass('graph');
          },
          'onClosed' : function(){
            $('#fancybox-wrap').removeClass('graph');
          },
          'onComplete': function() {
            $('#fancybox-close').hide();
          }
        });
      }, 'html');
  });
}
  
  
  
  
  
  //turn off submit for #mini_search
  $('#item_form').submit(function() {return false;});

  $('.add').each(function() {

    var el = $(this);
    var el_id = $(this).attr('ref');
    //attach remove button
    $('#' + el_id + '_remove').click(function() {
      noChanges=false;
      cleanItem(el_id);
      $(this).hide();
    });

    function cleanItem(el_id) {
      $(".edit a[ref=" + el_id + "].add").hide();
      $('#' + el_id + '_field').attr("value", '');
      $('#' + el_id + '_item_name').html("");
      $('#' + el_id + '_item_image').attr('src', '').hide();
      $('#' + el_id + '_item_rating').hide();
      $('#' + el_id + '_item_label').show();
      $('#' + el_id + '_add_button').show();

      return false;
    }

    $(el).fancybox(
      {
      'autoDimensions'  : false,
      'width'           : 630,
      'height'          : 215,
      'padding'         : 0,
      'onStart'         : function() {
                            //clear old sub-categories
                            $('.selector').html('');
                             //display help text
                             if(($('#help_text1').attr('id')))
                            {   
                              var new_el_id;
                              $('#help_text1').html('All-Time Top Hyped: ');
                              if (el_id=='events') { new_el_id="event" }
                              else if (el_id=='movies') { new_el_id="movie" }
                              else if (el_id=='products') { new_el_id="product" }
                              else if (el_id=='music-1') { new_el_id="music" }
                              else {new_el_id=el_id}
                              $('#help_text2').html(new_el_id);
                            }
                            //clear old result
                            $('#result_item_id').val('');
                            //add subcategories to step1
                            cat_id = el_id;
                            var subcategories = $('.' + el_id + '_sub');
                            if (subcategories.length > 0) {
                              var label = $('#'+cat_id+'_item_label').text();
                              $('.selector').append('<span class="sub-label">What type of ' + label + ' Item is this?</span>');
                              subcategories.each(function(e) {
                                $('.selector').append('<span id=' + $(this).attr('id') + ' class="sub-button">' + $(this).attr('name') + '</span>' );
                              });
                              //select/deselect sub-categories buttons
                              $('.sub-button').each(function() {
                                var el = $(this);
                                $(el).click(function() {
                                  $('.selector span[value=selected]').attr('value', '').css({
                                    'backgroundColor':'#fff',
                                    'color':'#888'
                                    });
                                  $(el).attr('value', 'selected').css({
                                    'backgroundColor':'#888',
                                    'color':'#fff'
                                    });

                                });
                                
                              });

                              $('.selector span.sub-button:first').attr('value', 'selected').css({
                                'backgroundColor':'#888',
                                'color':'#fff'
                              });
                            }


                            setDefultInputText();
                            $('#step_2').hide();
                            $('#not_found').hide();
                            $('#step_1').show();
                            
                         },
      'onClosed'        : function() {
                            $('#popup').show();
                            $('#mini_search').val("");
                            setDefultInputText();
                            $('#step_1').show();
                            $('#step_2').hide();

                          }
      }
    );
  });

  function truncateName(text) {
    if (text.length >= 15) {
      text = text.slice(0, 15) + "...";
    }

    return text;
  }

  $('#find_item').click(function() {
    $('#spinner').show();

    search_value = $("span#result_item_id").val();
    search_name = truncateName($("span#result_item_name").val());

    if (!search_value) {
      search_value = $('#mini_search').val();
      search_name = truncateName(search_value);
    }

    var selected = $(".selector span[value=selected]");
    if (selected.length == 1) {
      sub_id = selected.attr('id');
    } else {
      sub_id = cat_id;
    }
    //compose url
    url = '/items/' + search_value + '?category=' + sub_id;

    //get item data
    $.getJSON(url , function(data) {
      $data = data;
      if (data['status'] == "found") {
        // set item image src
        $('#item_image_url').attr({src: data["image_path"]});
        
        var categ;
        categ = sub_id.split("-")[0];
        categ[0] = categ[0].toUpperCase();
        //show selected category
        $('.category-name').html(data['category']);
        $('.item_name').html(search_name);
        $('.item_name_link').html('<a href="/items/' + data["id"] + '">' + search_name + '</a>')

        //compose url for hyping
        if (data['already_hyped']==true) {
        var url = '/already_hyped/' + data['id'];
          } else {
        var url = '/items/' + data['id'] + '/reviews/new?wizard=true';
          }
          $('a.hype-item').attr({href: url});
        



        // toggle popup screens and hide spinner
        toggleSteps();
        $('#fancybox-wrap').css({'height' : '300px'});
        $('#fancybox-inner').css({'height' : '300px'});

        //add item to the form
        $('#add').click(function() {
          $.addItemToForm(data);
          $.fancybox.close();
        });
      } else {
        $('#spinner').hide();
        $('#step_1').toggle();
        $('#not_found').toggle();

        $('#add_item').attr('href', '/items/new?query=' + search_value);
      }
    });
  });


  $('#back').click(function() {
    $('#result_item_id').val('');
    $('#fancybox-wrap').css({'height' : '215px'});
    $('#fancybox-inner').css({'height' : '215px'});
    toggleSteps();
  }); 
  $('.cancel').click(function() {$.fancybox.close();});
  $('.back2').click(function() {$('#not_found').hide();$('#step_1').show();});
  //redirect to homepage instead of step 3
  $('#submit2').click(function() {
    var form = $("form#top-items");
    var form_url = form.attr('action');
    form.attr('action', form_url + "?ref=" + $(this).attr('ref'));
    form.submit();
  });

  function toggleSteps() {
    $('#step_1').toggle();
    $('#step_2').toggle();
    $('#spinner').hide();
  }

  
  function setDefultInputText() {
    $('#mini_search').example('');
    $('#mini_search').click(function(){
      if($(this).val() == 'Find Items, People, Tags') {$(this).val('');}
    });
  }


  $('#mini_search').autocomplete('/items/autocomplete', {
    mustMatch : false,
    cacheLength: 1,
    max: 15,
    scroll: false,
    selectFirst: false,
    extraParams: {category: function() {
                              var selected = $(".selector span[value=selected]");
                              if (selected.length == 1) {
                                return selected.attr('id');
                              } else {
                                return cat_id;
                              }
                            }},
    autoFill: false
  });
  $('#mini_search').result(function (event, data, formatted) {
    $(this).siblings('span#result_item_id').val( !data ? '' : data[1]);
    $(this).siblings('span#result_item_name').val( !data ? '' : data[0]);
  });
});
