let keyCode = 'KeyK';
let htmlDebug = false;
let hasGuild = htmlDebug;
let data = {};
data.list = [];
data.ranking = [];
let confirmOpen = false;

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
            setupRanking();

            if(item.information){
                //information
                setupInformation(item.information,true);

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
                $(".content").removeClass('selected');
                $(".menuButton").removeClass('btnSelected');
                hasGuild = false;
            }

            $("#self-name").text(item.selfName);
            $("#self-lv").text("Lv."+item.selfLv);

            //search
            buf = "";
            for(let i=0; i<data.list.length; i++)
            {
                if(data.list[i]){
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ data.list[i].name+'</td> <td>'+ data.list[i].players+'</td> <td>'+ data.list[i].point+'</td><td><button class="search-join" id="join-'+data.list[i].name+'">申請加入</button><button class="search-information" id="information-'+data.list[i].name+'">公會資訊</button></td> </tr>';
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

            if(page == "information"&& !htmlDebug){
                setupInformation(data.information,true);
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
            if(confirmOpen){  
                $("#confirmWindow").hide();
                confirmOpen = false;
            }
            else{
                $.post('https://Guild/close', JSON.stringify({}));
                display(false);
            }
        }
        if (event.code === keyCode) {
            if(!confirmOpen){ 
                $.post('https://Guild/close', JSON.stringify({}));
                display(false);
            }
        }
    }

    $("#close").click(function() { 
        display(false);
        $.post('https://Guild/close', JSON.stringify({}));
    });

    $("#leaveGuild").click(function() {
        $("#confirmWindow").show();
        confirmOpen = true;
    });

    $("#confirm-button-yes").click(function() {
        $("#confirmWindow").hide();
        confirmOpen = false;
        $.post('https://Guild/leave', JSON.stringify({}));
        $(".content").removeClass('selected');
        $(".menuButton").removeClass('btnSelected');
    });

    $("#confirm-button-no").click(function() {
        $("#confirmWindow").hide();
        confirmOpen = false;
    });

    $("#search-button").click(function(){
        let input = $("#search-input").val();

        let buf = "";
        let count = 1;
        for(let i=0; i<data.list.length; i++)
        {
            if(data.list[i]){
                if(data.list[i].name.includes(input)){
                    buf = buf + '<tr><td>'+(count)+'</td> <td>'+ data.list[i].name+'</td> <td>'+ data.list[i].players+'</td> <td>'+ data.list[i].point+'</td><td><button class="search-join" id="join-'+data.list[i].name+'">申請加入</button><button class="search-information" id="information-'+data.list[i].name+'">公會資訊</button></td> </tr>';
                    count++;
                }
            }
        }
        $("#search table tbody").html(buf);
        $(".search-join").attr("disabled",hasGuild);
    });

    $("#search").on("click", ".search-join", function(){
        $(".search-join").attr("disabled",true);
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

        for(let i=0; i<data.list.length; i++)
        {
            if(data.list[i]){
                if(data.list[i].name == guildName){
                    setupInformation(data.list[i],false);
                    break;
                }
            }
        }
    });
});


function setupInformation(guild,selfGuild){
    $("#information-name").text(guild.name);
    $("#information-point").text(guild.point);
    $("#information-players").text(guild.players);
    $("#information-chairman").text(guild.chairman);
    $("#information-comment").text(guild.comment);
        
    let buf = "";
    for(let i=0; i<data.ranking.length; i++)
    {
        if(data.ranking[i].name == guild.name){
            if(i){
                for(let j=i-1;j<i+2;j++){
                    if(data.ranking[j]){
                        if(j==i)
                            buf = buf + '<tr style="background-color: rgb(60,60,60);"><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ data.ranking[j].point+'</td> </tr>';
                        else
                            buf = buf + '<tr><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ data.ranking[j].point+'</td> </tr>';
                    }
                    else{
                        buf = buf + '<tr><td>'+(j+1)+'</td> <td></td> <td></td> </tr>';
                    }
                }
            }
            else{
                for(let j=0;j<3;j++){
                    if(data.ranking[j]){
                        if(!j)
                            buf = buf + '<tr style="background-color: rgb(60,60,60);"><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ data.ranking[j].point+'</td> </tr>';
                        else
                            buf = buf + '<tr><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ data.ranking[j].point+'</td> </tr>';
                    }
                    else{
                        buf = buf + '<tr><td>'+(j+1)+'</td> <td></td> <td></td> </tr>';
                    }
                }
            }
            break;
        }
    }
    $("#information-ranking table tbody").html(buf);

    if(selfGuild){
        $("#leaveGuild").show();
    }
    else{
        $("#leaveGuild").hide();
    }
}

function setupRanking(){
    let ranking = [];
    for(let i=0; i<data.list.length; i++)
    {
        if(data.list[i])
        {
            let j = 0;
            for(; j<ranking.length; j++){
                if(ranking[j].point<data.list[i].point)
                    break;
            }
            ranking.splice(j,0,data.list[i]);
        }
    }
    data.ranking = ranking;

    let buf = "";
    for(let i=0; i<data.ranking.length; i++)
    {
        if(data.ranking[i]){
            buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ data.ranking[i].name+'</td> <td>'+ data.ranking[i].chairman+'</td> <td>'+ data.ranking[i].point+'</td> </tr>';
        }
    }
    $("#ranking table tbody").html(buf);
}