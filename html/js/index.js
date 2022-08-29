//===========================config===========================
let htmlDebug = false;
let keyCode = 'KeyK';
let gradePermission = [
    {
        name: "申請中",
        editGuild: false,
        joinApply: false,
        kickMember: false,
        changeGrade: false,
        upgradeGuild: false
    },
    {
        name: "成員",
        editGuild: false,
        joinApply: false,
        kickMember: false,
        changeGrade: false,
        upgradeGuild: false
    },
    {
        name: "秘書",
        editGuild: false,
        joinApply: true,
        kickMember: true,
        changeGrade: false,
        upgradeGuild: false
    },
    {
        name: "副會長",
        editGuild: false,
        joinApply: true,
        kickMember: true,
        changeGrade: false,
        upgradeGuild: true
    },
    {
        name: "會長",
        editGuild: true,
        joinApply: true,
        kickMember: true,
        changeGrade: true,
        upgradeGuild: true
    }
]
let upgradeCost = {
    money: 15000,
    point: 5000
}

//============================================================

let hasGuild = htmlDebug;
let data = {};
data.list = [];
data.ranking = [];
let confirmBoxData = {
    text:"",
    yesCallBack:()=>{},
    noCallBack:()=>{},
    isOpen:false};

let editingGuild = false;

function display(bool) {
    if (bool)
        $("#container").show();
    else
        $("#container").hide();
}

display(htmlDebug);

$(function(){
    //event
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

            if(item.guild){
                //information
                setupInformation(data.guild,true);

                //member
                setupMember(data.guild,true);

                hasGuild = true;
            }
            else{
                $(".content").removeClass('selected');
                $(".menuButton").removeClass('btnSelected');
                hasGuild = false;
            }

            //self info
            $("#self-name").text(item.player.name);
            $("#self-lv").text("Lv."+item.player.level);

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
    
    //side menu btn click
    $(".menuButton").click(function () {
        if(hasGuild && !editingGuild){
            
            let page = $(this).attr("id");
            page = page.substring(5);

            if(page == "information"&& !htmlDebug){
                setupInformation(data.guild,true);
            }
            
            $(".content").removeClass('selected');
            $(".menuButton").removeClass('btnSelected');
            $("#content-"+page).addClass('selected');
            $(this).addClass('btnSelected');
        }
    });
    
    //find guild btn click
    $("#findGuild").click(function(){
        if(!editingGuild){
            $(".content").removeClass('selected');
            $(".menuButton").removeClass('btnSelected');
            $("#content-search").addClass('selected');
        }
    });
    
    document.onkeyup = function(event){
        if (event.code === "Escape") {
            if(editingGuild){
                $("#editGuild").trigger( "click" );
            }
            else if(confirmBoxData.isOpen){
                $("#confirm-button-no").trigger( "click" );
            }
            else{
                $.post('https://Guild/close', JSON.stringify({}));
                display(false);
            }
        }
        if (event.code === keyCode) {
            if(!confirmBoxData.isOpen&&!editingGuild){ 
                $.post('https://Guild/close', JSON.stringify({}));
                display(false);
            }
        }
    }

    $("#close").click(function() { 
        if(editingGuild){
            $("#editGuild").trigger( "click" );
        }
        else{
            display(false);
            $.post('https://Guild/close', JSON.stringify({}));
        }
    });

    //edit guild btn click
    $("#editGuild").click(function () {
        let originName = data.guild.name;
        let originComment = data.guild.comment;
        if(editingGuild){
            let editName = $("#newGuildName").val();
            let editComment = $("#newGuildComment").val();
            if(editName==""){
                editName = originName;
            }
            if(editComment == ""){
                editComment = originComment;
            }

            if(originComment!=editComment||originName!=editName){
                confirmBoxData = {
                    text:"是否要儲存編輯",
                    yesCallBack:()=>{
                        data.guild.name = editName;
                        data.guild.comment = editComment;
                        $.post('https://Guild/edit', JSON.stringify({
                            name : editName,
                            comment : editComment
                        }));
                    },
                    noCallBack:()=>{
                        $("#information-name").text(data.guild.name);
                        $("#information-comment").text(data.guild.comment);
                    },
                    isOpen:false};
                ConfirmBox(confirmBoxData);
            }
            $("#information-name").text(editName);
            $("#information-comment").text(editComment);
            $("#editGuild").text("編輯公會");
            if(gradePermission[data.player.grade].editGuild){
                $("#editGuild").show();
            }else{
                $("#editGuild").hide();
            }
            if(gradePermission[data.player.grade].upgradeGuild){
                $("#upgradeGuild").show();
            }else{
                $("#upgradeGuild").hide();
            }
        }
        else{
            $("#editGuild").text("結束編輯");
            $("#information-name").html('<input id="newGuildName" value="'+ originName +'">')
            $("#information-comment").html('<textarea id="newGuildComment">' + originComment +'</textarea>')
            $("#upgradeGuild").hide();
            $("#leaveGuild").hide();
        }
        editingGuild = !editingGuild;
    });

    //upgrade guild btn click
    $("#upgradeGuild").click(function () {
        if(!editingGuild){
            $(".content").removeClass('selected');
            $(".menuButton").removeClass('btnSelected');
            $("#content-upgrade").addClass('selected');
        }
    });

    $('#upgradeButton').click(function() {
        $.post('https://Guild/upgrade', JSON.stringify({}));
    });

    //leave guild btn click
    $("#leaveGuild").click(function() {
        confirmBoxData = {
            text:"確認是否要退出",
            yesCallBack:()=>{
                $.post('https://Guild/leave', JSON.stringify({}));
                $(".content").removeClass('selected');
                $(".menuButton").removeClass('btnSelected');
            },
            noCallBack:()=>{},
            isOpen:false};
        ConfirmBox(confirmBoxData);
    });

    //member apply page click
    $("#join-apply").click(function() {
        $(".content").removeClass('selected');
        $("#content-member-apply").addClass('selected');
    });

    //click a member show option list 
    let identifier="";
    $("#member").on("click",".memberRow",function(e){
        //show the
        if(!htmlDebug){
            identifier = $(this).attr("id");
            identifier = identifier.substring(7); 
            
            showChangeGrade = function (bool) {
                if(bool)
                    $("#member-changeGrade").show();
                else
                    $("#member-changeGrade").hide();
            }
            showKick = function (bool) {
                if(bool)
                    $("#member-kick").show();
                else
                    $("#member-kick").hide();
            }
            
            showChangeGrade(gradePermission[data.player.grade].changeGrade);
            showKick(gradePermission[data.player.grade].kickMember);
        }

        //show memberOption
        let toggle=true;
        if ($("#memberOption").css("display") == "none"){
            $("#memberOption").show();
        }
        document.onclick = function(){
            if(!toggle){
                $("#memberOption").hide();
            }
            toggle=false;
        }
        $("#memberOption").css("left",e.pageX+"px");
        $("#memberOption").css("top",e.pageY+"px");

        //if choose it self don't show
        if(identifier==data.player.identifier){
            $("#memberOption").hide();
        }
    });

    //memberOption click event
    $(".changeGrade").click(function(){
        $("#memberOption").hide();
        let grade = $(this).attr("id");
        grade = grade.substring(13)
        $.post('https://Guild/changeGrade', JSON.stringify({
            identifier : identifier,
            grade : Number(grade)
        }));
    });
    $("#member-chat").click(function(){
        $("#memberOption").hide();
        $.post('https://Guild/chat', JSON.stringify({
            identifier : identifier
        }));
    });
    $("#member-kick").click(function(){
        $("#memberOption").hide();
        $.post('https://Guild/kick', JSON.stringify({
            identifier : identifier
        }));
    });
    
    //member apply yes
    $("#content-member-apply").on("click",".apply-yes", function(){
        let identifier = $(this).attr("id");
        identifier = identifier.substring(10);

        $.post('https://Guild/apply', JSON.stringify({
            identifier : identifier,
            accept : true
        }));
    });

    //member apply no
    $("#content-member-apply").on("click",".apply-no", function(){
        let identifier = $(this).attr("id");
        identifier = identifier.substring(9);

        $.post('https://Guild/apply', JSON.stringify({
            identifier : identifier,
            accept : false
        }));
    });

    //search
    $("#search-button").click(function(){
        let input = $("#search-input").val();

        let buf = "";
        let count = 1;
        for(let i=0; i<data.list.length; i++)
        {
            if(data.list[i]){
                if(data.list[i].name.includes(input)){
                    buf = buf + '<tr><td>'+(count)+'</td> <td>'+ data.list[i].name+'</td> <td>'+ data.list[i].players+'</td> <td>'+ 'Lv.'+data.list[i].level+'</td> <td>'+ data.list[i].point+'</td><td><button class="search-join" id="join-'+data.list[i].name+'">申請加入</button><button class="search-information" id="information-'+data.list[i].name+'">公會資訊</button></td> </tr>';
                    count++;
                }
            }
        }
        $("#search table tbody").html(buf);
        $(".search-join").attr("disabled",hasGuild);
    });

    //search join click
    $("#search").on("click", ".search-join", function(){
        $(".search-join").attr("disabled",true);
        let guildName = $(this).attr("id");
        guildName = guildName.substring(5);

        $.post('https://Guild/join', JSON.stringify({
            name : guildName
        }));
    });

    //search information click
    $("#search").on("click", ".search-information", function(){
        let guildName = $(this).attr("id");
        guildName = guildName.substring(12);

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
    $("#information-point").text(Number(guild.point).toLocaleString('en'));
    $("#information-players").text(String(guild.players) + '/' + String(Math.floor((guild.level-1)/3)*5 + 20));
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
                            buf = buf + '<tr style="background-color: rgb(60,60,60);"><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ 'Lv.'+data.ranking[j].level+'</td> <td>'+ data.ranking[j].point.toLocaleString('en')+'</td> </tr>';
                        else
                            buf = buf + '<tr><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ 'Lv.'+data.ranking[j].level+'</td> <td>'+ data.ranking[j].point.toLocaleString('en')+'</td> </tr>';
                    }
                    else{
                        buf = buf + '<tr><td>'+(j+1)+'</td> <td></td> <td></td> <td></td> </tr>';
                    }
                }
            }
            else{
                for(let j=0;j<3;j++){
                    if(data.ranking[j]){
                        if(!j)
                            buf = buf + '<tr style="background-color: rgb(60,60,60);"><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ 'Lv.'+data.ranking[j].level+'</td> <td>'+ data.ranking[j].point.toLocaleString('en')+'</td> </tr>';
                        else
                            buf = buf + '<tr><td>'+(j+1)+'</td> <td>'+ data.ranking[j].name+'</td> <td>'+ 'Lv.'+data.ranking[j].level+'</td> <td>'+ data.ranking[j].point.toLocaleString('en')+'</td> </tr>';
                    }
                    else{
                        buf = buf + '<tr><td>'+(j+1)+'</td> <td></td> <td></td> <td></td> </tr>';
                    }
                }
            }
            break;
        }
    }
    $("#information-ranking table tbody").html(buf);

    if(selfGuild){
        if(gradePermission[data.player.grade].editGuild){
            $("#editGuild").show();
        }else{
            $("#editGuild").hide();
        }
        if(gradePermission[data.player.grade].upgradeGuild){
            $("#upgradeGuild").show();
            //upgrade information setup
            $('#upgrade-money span:nth-child(2)').text(guild.money.toLocaleString('en'));
            $('#upgrade-point span:nth-child(2)').text(guild.point.toLocaleString('en'));
            $('#upgrade-lv').text('Lv.'+guild.level);
            $('#upgrade-players').text(String(guild.players) + '/' + String(Math.floor((guild.level-1)/3)*5 + 20));

            let moneyCost = upgradeCost.money * guild.level;
            let pointCost = upgradeCost.point * guild.level;
            $('#need-money').text(moneyCost.toLocaleString('en'));
            $('#need-point').text(pointCost.toLocaleString('en'));

            if(guild.point<pointCost || guild.money<moneyCost){
                $('#upgradeButton').attr("disabled",true);
            }else{
                $('#upgradeButton').attr("disabled",false);
            }
        }else{
            $("#upgradeGuild").hide();
        }
        $("#leaveGuild").show();
    }
    else{
        $("#editGuild").hide();
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
                if(ranking[j].level<data.list[i].level || (ranking[j].level===data.list[i].level&&ranking[j].point<data.list[i].point))
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
            buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ data.ranking[i].name+'</td> <td>'+ data.ranking[i].chairman+'</td> <td>'+ 'Lv.'+data.ranking[i].level+'</td> <td>'+ data.ranking[i].point.toLocaleString('en')+'</td> </tr>';
        }
    }
    $("#ranking table tbody").html(buf);
}

function setupMember(guild,selfGuild){
    let member = guild.member;
    buf = "";
    for(let i=0; i<member.length; i++)
    {
        if(member[i]){
            buf = buf + '<tr class="memberRow" id="member-'+member[i].identifier+'"><td class = "member-num">'+(i+1)+'</td> <td class = "member-name">'+ member[i].name+'</td> <td class = "member-job">'+ member[i].job+'</td> <td class = "member-rank">'+ member[i].rank+'</td> <td class = "member-grade">'+ gradePermission[member[i].grade].name+'</td> <td class = "member-point">'+ member[i].point+'</td> </tr>';
        }
    }
    $("#member table tbody").html(buf);

    if(selfGuild){
        let apply = guild.apply
        buf = "";
        for(let i=0; i<apply.length; i++)
        {
            if(apply[i]){
                buf = buf + '<tr><td class = "apply-num">'+(i+1)+'</td> <td class = "apply-name">'+ apply[i].name+'</td> <td class = "apply-job">'+ apply[i].job+'</td> <td class = "apply-rank">'+ apply[i].rank+'</td> <td><button class="apply-yes" id="apply-yes-'+apply[i].identifier+'">接受</button><button class="apply-no" id="apply-no-'+apply[i].identifier+'">拒絕</button></td></tr>';
            }
        }
        $("#member-apply table tbody").html(buf);

        if(gradePermission[data.player.grade].joinApply){
            $("#join-apply").show();
            $("#join-apply-num").text(apply.length)
        }
        else{
            $("#join-apply").hide();
        }
    }
}