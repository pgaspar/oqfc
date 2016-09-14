 $(document).ready(function() {
    $("#bt-dw,#bt-up").click(function (event) {
        event.preventDefault();
        const id =  $(this).parent().attr("value");
        const up = $(this).attr("value");
        const curr = $(this);
        $.post("/vote?entry_id=" + id + "&up=" + up, function(){
                $.get("/" + id + "/vote_score", function(data){
                    $("#vote_score_" + id).html(data);
                    curr
                        .siblings().andSelf()
                        .prop("disabled","true");
                })
        })
    })
})
    
