 $(document).ready(function() {
    $("#bt-dw,#bt-up").click(function (event) {
        const vote_page = $(this).parent().parent().attr("value");
        event.preventDefault();

        const id =  $(this).parent().attr("value");
        const up = $(this).attr("value");
        const curr = $(this);
        let ext = $("<div></div>");

        $.post("/vote","entry_id=" + id + "&up=" + up,function(response){
            ext.html(response);
            if(vote_page=="false") {
              $("#suggestion-" + id + " .suggestion-votes").html($("#suggestion-" + id + " .suggestion-votes", ext).html());
            } else {
              $(".suggestion-votes").html($(".suggestion-votes", ext).html());
            }
          }
        )
    })
})
