
jQuery(document).ready(function($) {
    $('.more_less .more_less_link').bind('click', function(e){
      var link = $(this);
      var text_to_hide = link.closest('.more_less').children('.more');
      var ellipse = link.closest('.more_less').children('.ellipse');
      var is_hidden = text_to_hide.is(':hidden');
      if (is_hidden) {
        ellipse.hide();
        text_to_hide.show();
        link.text('less');
      } else {
        ellipse.show();
        text_to_hide.hide();
        link.text('more');
      }
      return false;
    });
});
