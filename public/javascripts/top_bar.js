jQuery(document).ready(function($) {
 
  if($('#query').val() == ''){
    $('#query').val('Find Items, People, Tags');
  }
    
  $('#query').click(function(){
    if($(this).val() == 'Find Items, People, Tags'){
       $(this).val('');
      }
  });
  $('#query').AutoComplete('/search_autocomplete?q=');
});

var result_Selected = -1;
var resultsId = "display";
var searchId = "search";
var searchUrl = "/search_autocomplete?q=";
var searchText = null;
var liResults  = null;

function setAutoComplete(searchId, searchUrl) {

	// initialize vars
    searchUrl = searchUrl;
    
	// register mostly used vars
	searchBox = $("#" + searchId);
    
	// create the results div
	
	// on blur listener
	searchBox.blur(function(){ setTimeout("clearResults()", 500); });

	// on key up listener
	searchBox.keyup(function (e) {

	    // get keyCode (window.event is for IE)
	    var keyCode = e.keyCode || window.event.keyCode;
	    var lastSearch = searchBox.val();

	    // check for an ENTER 
	    if (keyCode == 13) {
	        OnEnterClick();
	        return;
	    }

	    // check an treat up and down arrows
	    if (OnUpDownClick(keyCode)) {
	        return;
	    }

	    // check for an ESC
	    if (keyCode == 27) {
	        clearResults();
	        return;
	    }

	    // if is text, call with delay
	    setTimeout(function () { updateResults(lastSearch); }, 500);
	});
}

// treat the auto-complete action (delayed function)
function updateResults(lastSearchWord)
{
	// get the field value
	var searchWord = searchBox.val();

	// if it's empty clear the resuts box and return
	if(searchWord == ''){
		clearResults();
		return;
	}

        if (searchWord.length < 3){
             return;
        }

	// if it's equal the value from the time of the call, allow
	if(lastSearchWord != searchWord){
		return;
	}

	$.ajax({
	    type: "GET",
	    url: searchUrl +  searchWord,
	    cache: false,
	    success: function (html) {

	        // get the total of results
            
	        if (html.length > 0) {

                    $("#" + resultsId).html(html);
                    $("#" + resultsId).show();

	            // for all lis in results
	            var lis = $("#" +  resultsId + " ul li");
                
                //setting the number of suggested items
                result_Count = lis.size();

	            // on mouse over clean previous selected and set a new one
	            lis.mouseover(function () {
	                lis.each(function () { 
                            $(this).removeClass("selected"); });
	                $(this).addClass("selected");
	            });

	        }
	        else {
	            clearResults();
	        }
	    }
	});
}

// clear auto complete box
function clearResults()
{
	 $('#' + resultsId).html('');
	 $('#' + resultsId).hide();
}


// treat up and down key strokes defining the next selected element
function OnUpDownClick(keyCode) {
	if(keyCode == 40 || keyCode == 38){

		if(keyCode == 38){ // keyUp
			if(result_Selected == 0 || result_Selected == -1){
				result_Selected = result_Count-1;
			}else{
				result_Selected--;
			}
		} else { // keyDown
			if(result_Selected == result_Count-1){
				result_Selected = 0;
			}else {
				result_Selected++;
			}
		}
		// loop through each result div applying the correct style
		 $('#' + resultsId + ' ul').children().each(function(i){
		    if (i == result_Selected) {
		          $(this).addClass("selected");
			} else {
			  $(this).removeClass("selected");
			}
		});

		return true;
	} else {
		// reset
		result_Selected = -1;
		return false;
	}
}
function OnEnterClick() {
    $('#' + resultsId + ' ul') .children().each(function (i) {
        if (i == result_Selected) {
            window.location.href = $(this).attr('rel'); 
        }
    });
    clearResults();
}

function toPage(id){
  window.location.href = $('#' +id).attr('rel'); 
  return false;
}

(function ($) {

    $.fn.AutoComplete = function (searchUrl) {
        setAutoComplete($(this).attr("id"), searchUrl);
        return true;
    };
})(jQuery);

