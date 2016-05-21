jQuery(function ($) {

  $("#go-to-suggestions").click(function() {
    $('html,body').animate({scrollTop: $("#suggestions").offset().top},'medium');
    return false;
  });


  $("#suggestion-form").submit(function() {
    var len = $("#suggestion").val().length;

    if ( len < 1 || len > 300 ) {
      $("#warning").css({opacity: 0, visibility: "visible"}).animate({opacity: 1}, 150);
      return false;
    } else {
      $("#warning").css("visibility", "hidden");
    }
  });

  $("#separator").click(function() {
    var icon = $(this).find("i");
    var opening = !$(this).hasClass("open");

    if (opening) {  // Do Open
      $("#buried-entries").show();
      $(this).addClass("open");
      icon.addClass("icon-caret-up");
      icon.removeClass("icon-caret-down");
      $('html,body').animate({scrollTop: $("#separator").offset().top - 30},'medium');
    }
    else {  // Do Close
      $(this).removeClass("open");
      icon.addClass("icon-caret-down");
      icon.removeClass("icon-caret-up");

      $("html,body").animate({ scrollTop: $("#separator").offset().top + 30 - $(window).height()  }, 'medium', function() {
        $("#buried-entries").hide();
      });
    }
  });

  $(".sorting a.active").click(function() {
    return false;
  });

  setTimeout(function(){
    $('.comment-count').each(function() {
      var count = $('.fb_comments_count', this).text();

      if (count === "1") {
        $('.cm-label', this).html('comentário');
      }
    });
  }, 2000);

});
