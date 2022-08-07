let keyCode = 'KeyK';
let htmlDebug = false;
let hasGuild = htmlDebug;
let data = {};
let guildList = [];

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
            $("#search-input").val("");
        }
        else if (item.type === "setup") {
            data = item;
            guildList = item.list;

            if(item.information){
                //information
                setupInformation(item.information);

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

            //search
            buf = "";
            for(let i=0; i<guildList.length; i++)
            {
                if(guildList[i]){
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ guildList[i].name+'</td> <td>'+ guildList[i].players+'</td> <td>'+ guildList[i].point+'</td><td><button class="search-join" id="join-'+guildList[i].name+'">申請加入</button><button class="search-information" id="information-'+guildList[i].name+'">公會資訊</button></td> </tr>';
                }
                else
                {
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td></td> <td></td> <td></td> <td></td> </tr>';
                }
            }
            $("#search table tbody").html(buf);
            $(".search-join").attr("disabled",hasGuild);
        }
    });
    
    $(".menuButton").click(function () {
        if(hasGuild){
            
            let page = $(this).attr("id");
            page = page.substr(5);

            if(page == "information"){
                setupInformation(data.information);
            }
            
            $(".content").removeClass('selected');
            $(".menuButton").removeClass('btnSelected');
            $("#content-"+page).addClass('selected');
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

    $("#search-button").click(function(){
        let input = $("#search-input").val();

        let buf = "";
        for(let i=0; i<guildList.length; i++)
        {
            if(guildList[i]){
                if(guildList[i].name.includes(input)){
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ guildList[i].name+'</td> <td>'+ guildList[i].players+'</td> <td>'+ guildList[i].point+'</td><td><button class="search-join" id="join-'+guildList[i].name+'">申請加入</button><button class="search-information" id="information-'+guildList[i].name+'">公會資訊</button></td> </tr>';
                }
            }
        }
        $("#search table tbody").html(buf);
        $(".search-join").attr("disabled",hasGuild);
    });

    $("#search").on("click", ".search-join", function(){
        let guildName = $(this).attr("id");
        guildName = guildName.substr(5)

        $.post('https://Guild/join', JSON.stringify({
            name : guildName
        }));
    });

    
    $("#search").on("click", ".search-information", function(){
        let guildName = $(this).attr("id");
        guildName = guildName.substr(12)

        $(".content").removeClass('selected');
        $(".menuButton").removeClass('btnSelected');
        $("#content-information").addClass('selected');

        for(let i=0; i<guildList.length; i++)
        {
            if(guildList[i]){
                if(guildList[i].name == guildName){
                    setupInformation(guildList[i]);
                    break;
                }
            }
        }
    });
});


function setupInformation(guild){
    $("#information-name").text(guild.name);
    $("#information-point").text(guild.point);
    $("#information-players").text(guild.players);
    $("#information-comment").text(guild.comment);
    
    let ranking = [];
    for(let i=0; i<guildList.length; i++)
    {
        if(guildList[i])
        {
            let j = 0;
            for(; j<ranking.length; j++){
                if(ranking[j].point<guildList[i].point)
                    break;
            }
            ranking.splice(j,0,guildList[i]);
        }
    }
    let buf = "";
    for(let i=0; i<ranking.length; i++)
    {
        if(ranking[i].name == guild.name){
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
}