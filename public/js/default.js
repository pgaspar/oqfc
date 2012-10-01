jQuery(function ($) {

  $("#go-to-suggestions").click(function() {
    $('html,body').animate({scrollTop: $("#suggestions").offset().top},'medium');
    return false;
  });

});
