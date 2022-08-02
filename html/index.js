let keyCode = 'KeyK';
let htmlDebug = false;
let hasGuild = htmlDebug;

function display(bool) {
    if (bool)
        $("#container").show();
    else
        $("#container").hide();
}

display(htmlDebug);//false

$(function(){
    window.addEventListener("message",function(event){
        let item = event.data
        if (item.type === "open") {
            display(true);
            if(!hasGuild){
                $(".content").removeClass('selected');
                $(".menuButton").removeClass('btnSelected');
            }
        }
        else if (item.type === "setup") {
            if(item.information.name){
                $("#information-name").text(item.information.name);
                $("#information-point").text(item.information.point);
                $("#information-players").text(item.information.players);
                $("#information-comment").text(item.information.comment);
                
                let ranking = item.information.ranking;
                let buf = "";
                for(let i=0; i<3; i++)
                {
                    if(ranking[i]){
                        buf = buf + '<tr><td class = "ranking-num">'+ranking[i].num+'</td> <td class = "ranking-name">'+ ranking[i].name+'</td> <td class = "ranking-point">'+ ranking[i].point+'</td> </tr>';
                    }
                    else
                    {
                        buf = buf + '<tr><td class = "ranking-num">'+(i+1)+'</td> <td class = "ranking-name"></td> <td class = "ranking-point"></td> </tr>';
                    }
                }
                $("#information-ranking table tbody").html(buf);

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
            display(false);
            return;
        }
        if (event.code === keyCode) {
            $.post('https://Guild/close', JSON.stringify({}));
            display(false);
            return;
        }
    }

    $("#close").click(function() { 
        display(false);
        $.post('https://Guild/close', JSON.stringify({}));
    });


});
