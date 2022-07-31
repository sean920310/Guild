let keyCode = 'KeyK'
let hasGuild = false;

function display(bool) {
    if (bool)
        $("#container").show();
    else
        $("#container").hide();
}

display(false);//false

$(function(){
    window.addEventListener("message",function(event){
        let item = event.data
        if (item.type === "open") {
            display(true)
            if(!hasGuild){
                $(".content").removeClass('selected');
                $(".menuButton").removeClass('btnSelected');
            }
        }
        else if (item.type === "setupInformation") {
            if(item.name){
                $("#information-name").text(item.name);
                $("#information-point").text(item.point);
                $("#information-players").text(item.players);
                $("#information-comment").text(item.comment);
                
                hasGuild = true;
            }
            else{
                hasGuild = false;
            }

            $("#self-name").text(item.selfName);
            $("#self-lv").text("Lv."+item.selfLv);
        }
    });
    
    $(".menuButton").click(function () {
        if(hasGuild){
            let buf = $(this).attr("id");
            buf = buf.substr(5);
            $(".content").removeClass('selected');
            $(".menuButton").removeClass('btnSelected');
            $("#content-"+buf).addClass('selected');
            $(this).addClass('btnSelected');
        }
    });
    
    $("#findGuild").click(function(){
        $(".content").removeClass('selected');
        $(".menuButton").removeClass('btnSelected');
        $("#content-search").addClass('selected');
    });
    
    document.onkeyup = function(event){
        if (event.code === "Escape") {
            $.post('https://Guild/close', JSON.stringify({}));
            display(false)
            return;
        }
        if (event.code === keyCode) {
            $.post('https://Guild/close', JSON.stringify({}));
            display(false)
            return;
        }
    }

    $("#close").click(function() { 
        display(false)
        $.post('https://Guild/close', JSON.stringify({}));
    });


});
