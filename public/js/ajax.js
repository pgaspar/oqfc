 $(document).ready(function() {
    $("#bt-dw,#bt-up").click(function (event) {
        event.preventDefault();
        const id =  $(this).parent().attr("value");
        const up = $(this).attr("value");
        const curr = $(this);
        let ext = $("<div></div>");

        $.ajax({
          type:"POST",
          url:"/vote",
          data: "entry_id=" + id + "&up=" + up,
          success: function(response){
            ext.html(response);
            $("#suggestion-" + id + " .suggestion-votes").html($("#suggestion-" + id + " .suggestion-votes", ext).html());
          }
        })

    })
})
