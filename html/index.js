function display(bool) {
    if (bool)
        $("#container").show();
    else
        $("#container").hide();
}

function changePage(){
    
}

display(true);

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
        $(".content").addClass('notSelected');
        $("#content-"+buf).removeClass('notSelected');
        $("#content-"+buf).addClass('selected');
    });
    $("#findGuild").click(function(){
        $(".content").removeClass('selected');
        $(".content").addClass('notSelected');
        $("#content-search").removeClass('notSelected');
        $("#content-search").addClass('selected');
    });
});
