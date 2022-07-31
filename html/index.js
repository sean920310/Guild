function display(bool) {
    if (bool)
        $("#container").show();
    else
        $("#container").hide();
}

function changePage(){
    
}

display(false);//false

$(function(){
    window.addEventListener("message",function(event){
        let item = event.data
    
    });
    $("#close").click(function() { 
        display(false)
        //post return
    });

    $(".menuButton").click(function () {
        let buf = $(this).attr("id");
        buf = buf.substr(5);
        $(".content").removeClass('selected');
        $(".menuButton").removeClass('btnSelected');
        $("#content-"+buf).addClass('selected');
        $(this).addClass('btnSelected');
    });
    $("#findGuild").click(function(){
        $(".content").removeClass('selected');
        $(".menuButton").removeClass('btnSelected');
        $("#content-search").addClass('selected');
    });
});
