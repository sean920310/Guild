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

            $(".content").removeClass('selected');
            $(".menuButton").removeClass('btnSelected');
            
            $(".search-join").attr("disabled",hasGuild);
        }
        else if (item.type === "setup") {
            if(item.information){
                //information
                $("#information-name").text(item.information.name);
                $("#information-point").text(item.information.point);
                $("#information-players").text(item.information.players);
                $("#information-comment").text(item.information.comment);
                
                let ranking = item.information.ranking;
                let buf = "";
                for(let i=0; i<ranking.length; i++)
                {
                    if(ranking[i].name == item.information.name){
                        if(i){
                            for(let j=i-1;j<i+2;j++){
                                if(ranking[j])
                                    buf = buf + '<tr><td class = "ranking-num">'+(j+1)+'</td> <td class = "ranking-name">'+ ranking[j].name+'</td> <td class = "ranking-point">'+ ranking[j].point+'</td> </tr>';
                                else
                                    buf = buf + '<tr><td class = "ranking-num">'+(j+1)+'</td> <td class = "ranking-name"></td> <td class = "ranking-point"></td> </tr>';
                            }
                        }
                        else{
                            for(let j=0;j<3;j++){
                                if(ranking[j])
                                    buf = buf + '<tr><td class = "ranking-num">'+(j+1)+'</td> <td class = "ranking-name">'+ ranking[j].name+'</td> <td class = "ranking-point">'+ ranking[j].point+'</td> </tr>';
                                else
                                    buf = buf + '<tr><td class = "ranking-num">'+(j+1)+'</td> <td class = "ranking-name"></td> <td class = "ranking-point"></td> </tr>';
                            }
                        }
                        break;
                    }
                }
                $("#information-ranking table tbody").html(buf);

                //member
                let member = item.member.member;
                buf = "";
                for(let i=0; i<member.length; i++)
                {
                    if(member[i]){
                        buf = buf + '<tr><td class = "member-num">'+(i+1)+'</td> <td class = "member-name">'+ member[i].name+'</td> <td class = "member-grade">'+ member[i].grade+'</td> <td class = "member-point">'+ member[i].point+'</td> </tr>';
                    }
                    else
                    {
                        buf = buf + '<tr><td class = "member-num">'+(i+1)+'</td> <td class = "member-name"></td><td class = "member-grade"></td> <td class = "member-point"></td> </tr>';
                    }
                }
                $("#member table tbody").html(buf);

                hasGuild = true;
            }
            else{
                hasGuild = false;
            }

            $("#self-name").text(item.selfName);
            $("#self-lv").text("Lv."+item.selfLv);

            let search = item.search;
            buf = "";
            for(let i=0; i<search.length; i++)
            {
                if(search[i]){
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ search[i].name+'</td> <td>'+ search[i].players+'</td> <td>'+ search[i].point+'</td><td><button class="search-join">申請加入</button><button class="search-information">公會資訊</button></td> </tr>';
                }
                else
                {
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td></td> <td></td> <td></td> <td></td> </tr>';
                }
            }
            $("#search table tbody").html(buf);
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
