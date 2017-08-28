jQuery(function ($) {

  $(document).on("click", "#bt-dw, #bt-up", function(event) {
    event.preventDefault();
    const vote_page = $(this).closest(".suggestion-votes").data("vote-page");
    const id = $(this).closest(".btn-group").data("entry-id");
    const up = $(this).attr("value");

    $.post("/vote", {entry_id: id, up: up},function(response){
      if(!vote_page) {
        $("#suggestion-" + id + " .suggestion-votes").html(response);
      } else {
        $(".suggestion-votes").html(response);
      }
    });
  });

});
