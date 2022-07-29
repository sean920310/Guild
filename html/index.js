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
    $(".menuButton").click(function () {
        let buf = $(this).attr("id");
        buf = buf.substr(5);
        $(".content").removeClass('selected');
        $(".content").addClass('notSelected');
        $("#content-"+buf).removeClass('notSelected');
        $("#content-"+buf).addClass('selected');
    });
});
