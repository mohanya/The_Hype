jQuery(document).ready(function($)
{
  var essentialSearches = $('.essential_search');
	essentialSearches.autocomplete('/items/autocomplete', {
    mustMatch : false,
    cacheLength: 1,
    max: 10,
    scroll: false,
    selectFirst: false,
    autoFill: false
  });
  essentialSearches.result(function (event, data, formatted) {
  	$(this).siblings('.essential_item_id').val( !data ? '' : data[1]);
  });
});
