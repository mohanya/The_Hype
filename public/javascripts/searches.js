jQuery(document).ready(function($)
{
	function search_hype(query, type, page, category_id, div_target){
		var waitSpinner = div_target.closest('.item-results').find('.wait');
		waitSpinner.show();
		$.get("/search/local", {query: query, page: page, type: type, category_id: category_id}, function(data)
	  {
			waitSpinner.hide();
	    div_target.html(data);
	    //$("img." + div_target.attr("id") + "_wait").hide();
	  },
	  'html'
	  );
	}

/*
	function update_paging(page, div_target)
	{
		$.get("/search/paging", {page: page}, function(data)
	  {
	    div_target.html(data);
	  },
	  'html'
	  );
	}
*/

	$('#searches .pagination').hide();
	
	var item_category = '';
	var item_page = 1;
	var user_page = 1;
	
	$('#items a.set_category').click(function(){
		$('#items a.selected').removeClass('selected');
		$(this).addClass('selected');
		item_page = 1;
		item_category = $(this).closest('li').find('.category_id').text();
		search_hype($('#query').val(), 'item', item_page, item_category, $('#items .results'));
		return false;
	});
	
	if ($('#items .results').length){
		search_hype($('#query').val(), 'item', item_page, item_category, $('#items .results'));
	}
	
	if ($('#users .results').length){
		search_hype($('#query').val(), 'user', user_page, '', $('#users .results'));
	}
	
	$('#items .paging a.next').click(function(){
		$('.pagination').show();
		$('.initial').hide();
		type = 'item';
		item_page ++;
		$('#items_page_number').text(item_page);
		search_hype($('#query').val(), type, item_page, item_category, $(this).parents('.paging').siblings('.results'));
		return false;
	});
	
	$('#items .paging a.previous.items').click(function(){
		type = 'item';
		item_page --;
		$('#items_page_number').text(item_page);
		search_hype($('#query').val(), type, item_page, item_category, $(this).parents('.paging').siblings('.results'));
		return false;
	});
	
	$('#users .paging a.next').click(function(){
		$('.pagination').show();
		$('.initial').hide();
		type = 'user';
		user_page ++;
		$('#users_page_number').text(user_page);
		search_hype($('#query').val(), type, user_page, '', $(this).parents('.paging').siblings('.results'));
		return false;
	});
	
	$('#users .paging a.previous.items').click(function(){
		type = 'user';
		user_page --;
		$('#users_page_number').text(user_page);
		search_hype($('#query').val(), type, item_page, '', $(this).parents('.paging').siblings('.results'));
		return false;
	});
	
/*
	$('.paging a.next').click(function(){
		var type = $(this).parents('.paging').siblings('.type').val();
		if(type == 'item')
		{
			item_page += 1;
			page = item_page;
		}
		if(type == 'user')
		{
			user_page += 1;
			page = user_page;
		}
		search_hype($('#query').val(), type, page, $(this).parents('.paging').siblings('.results'));
		return false;
	});
	
	$('.paging a.previous').click(function(){
		alert('previous');
		if(type == 'item')
		{
			item_page--;
			page = item_page;
		}
		if(type == 'user')
		{
			user_page--;
			page = user_page;
		}
		search_hype($('#query').val(), type, page, $(this).parents('.paging').siblings('.results'));
		return false;
	});
*/
});
