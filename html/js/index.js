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
        upgradeGuild: false,
        upgradeSkill: false
    },
    {
        name: "成員",
        editGuild: false,
        joinApply: false,
        kickMember: false,
        changeGrade: false,
        upgradeGuild: false,
        upgradeSkill: false
    },
    {
        name: "秘書",
        editGuild: false,
        joinApply: true,
        kickMember: true,
        changeGrade: false,
        upgradeGuild: false,
        upgradeSkill: false
    },
    {
        name: "副會長",
        editGuild: false,
        joinApply: true,
        kickMember: true,
        changeGrade: false,
        upgradeGuild: true,
        upgradeSkill: false
    },
    {
        name: "會長",
        editGuild: true,
        joinApply: true,
        kickMember: true,
        changeGrade: true,
        upgradeGuild: true,
        upgradeSkill: true
    }
]
let upgradeCost = {};
let shopItem = {};
let mission = {};

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
        if(item.type === "init"){
            upgradeCost = item.config.upgradeCost;
            shopItem = item.config.shopItem;
            mission = item.config.mission
        }
        else if (item.type === "open") {
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

                //skill
                setupSkill();

                //shop
                setupShop();

                //mission
                setupmission();

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
                    let isFull = (data.list[i].players >= (Math.floor((data.list[i].level-1)/3)*5 + 20));
                    let disabled = "enabled";
                    if(isFull||hasGuild){disabled="disabled";}
                    let applying = (data.list[i].name == data.player.apply)? "applying" : "";
                    buf = buf + '<tr><td>'+(i+1)+'</td> <td>'+ data.list[i].name+'</td> <td>'+ data.list[i].players+'</td> <td>'+ 'Lv.'+data.list[i].level+'</td> <td>'+ data.list[i].point+'</td><td><button class="search-join '+applying+'" id="join-'+data.list[i].name+'" '+disabled+'>申請加入</button><button class="search-information" id="information-'+data.list[i].name+'">公會資訊</button></td> </tr>';
                }
            }
            $("#search table tbody").html(buf);
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

    //skill upgrade click
    $(".skill-upgrade").click(function(){
        let skill = $(this).attr("id");
        skill = skill.substring(8);

        $.post('https://Guild/skillUpgrade', JSON.stringify({
            skill : skill
        }));
    });

    $(".shop-buy").click(function(){
        let item = $(this).attr("id");
        item = item.substring(4) + "_material";

        $.post('https://Guild/shop', JSON.stringify({
            item : item
        }));
    });

    //mission handin
    $("#mission").on("click",".mission-handin", function(){
        if(!($(this).attr('disabled'))){
            let temp = $(this).parent().attr("id");
            temp = temp.substring(8);
            let missionLevel = temp.substring(0,temp.indexOf('-'));
            let missionIndex = Number(temp.substring(temp.indexOf('-')+1));
            missionIndex+=1;
    
            $.post('https://Guild/missionHandin', JSON.stringify({
                level : missionLevel,
                index : missionIndex
            }));
        }
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
                    let isFull = (data.list[i].players >= (Math.floor((data.list[i].level-1)/3)*5 + 20));
                    let disabled = "enabled";
                    if(isFull||hasGuild){disabled="disabled";}
                    let applying = (data.list[i].name == data.player.apply)? "applying" : "";
                    buf = buf + '<tr><td>'+(count)+'</td> <td>'+ data.list[i].name+'</td> <td>'+ data.list[i].players+'</td> <td>'+ 'Lv.'+data.list[i].level+'</td> <td>'+ data.list[i].point+'</td><td><button class="search-join '+applying+'" id="join-'+data.list[i].name+'" '+disabled+'>申請加入</button><button class="search-information" id="information-'+data.list[i].name+'">公會資訊</button></td> </tr>';
                    count++;
                }
            }
        }
        $("#search table tbody").html(buf);
    });

    //search join click
    $("#search").on("click", ".search-join", function(){
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
    $("#information-level").text('Lv.'+guild.level);
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

            if(guild.level>=10){
                $('#upgrade-information>div:nth-child(1)').hide();
                $('#upgrade-information>div:nth-child(2)').hide();
            }
            else{
                $('#upgrade-information>div:nth-child(1)').show();
                $('#upgrade-information>div:nth-child(2)').show();
            }
            
            $('#upgrade-information').css("background-image", "url(asset/img/upgrade-"+guild.level+".png)")

            if(guild.point<pointCost || guild.money<moneyCost || guild.level>=10){
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
        $("#upgradeGuild").hide();
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

        let isFull = (guild.players >= (Math.floor((guild.level-1)/3)*5 + 20));
        $(".apply-yes").attr("disabled", isFull);

        if(gradePermission[data.player.grade].joinApply){
            $("#join-apply").show();
            $("#join-apply-num").text(apply.length)
        }
        else{
            $("#join-apply").hide();
        }
    }
}

function setupSkill(){
    let skill = data.guild.skill;
    $("#skill-point span:nth-child(2)").text(data.guild.skillPoint);
    for (let i = 0; i <= 5; i++) {
        $(".skill-progressBar").removeClass("progress-"+i);
    }
    $("#progress-XP").addClass("progress-"+skill.XP);
    $("#progress-attack").addClass("progress-"+skill.attack);
    $("#progress-treasure").addClass("progress-"+skill.treasure);
    $("#progress-defense").addClass("progress-"+skill.defense);
    $("#progress-recoverHP").addClass("progress-"+skill.recoverHP);
    $("#progress-recoverMP").addClass("progress-"+skill.recoverMP);
    
    $(".skill-upgrade").attr("disabled", false);
    if(data.guild.skillPoint<=0){
        $(".skill-upgrade").attr("disabled", true);
    }
    if(skill.XP>=5){
        $("#upgrade-XP").attr("disabled", true);
    }
    if(skill.attack>=5){
        $("#upgrade-attack").attr("disabled", true);
    }
    if(skill.treasure>=5){
        $("#upgrade-treasure").attr("disabled", true);
    }
    if(skill.defense>=5){
        $("#upgrade-defense").attr("disabled", true);
    }
    if(skill.recoverHP>=5){
        $("#upgrade-recoverHP").attr("disabled", true);
    }
    if(skill.recoverMP>=5){
        $("#upgrade-recoverMP").attr("disabled", true);
    }

    if(!gradePermission[data.player.grade].upgradeSkill){
        $(".skill-upgrade").attr("disabled",true);
    }
}

function setupShop(){
    $("#buy-green>span:nth-child(2)").text(shopItem.green_material.money.toLocaleString('en'));
    $("#buy-blue>span:nth-child(2)").text(shopItem.blue_material.money.toLocaleString('en'));
    $("#buy-purple>span:nth-child(2)").text(shopItem.purple_material.money.toLocaleString('en'));
    $("#buy-gold>span:nth-child(2)").text(shopItem.gold_material.money.toLocaleString('en'));
    $("#buy-red>span:nth-child(2)").text(shopItem.red_material.money.toLocaleString('en'));

    $("#green>.item-limit").text("可購買次數 "+(shopItem.green_material.limit - data.player.shop.green_material)+"/"+(shopItem.green_material.limit));
    $("#blue>.item-limit").text("可購買次數 "+(shopItem.blue_material.limit - data.player.shop.blue_material)+"/"+(shopItem.blue_material.limit));
    $("#purple>.item-limit").text("可購買次數 "+(shopItem.purple_material.limit - data.player.shop.purple_material)+"/"+(shopItem.purple_material.limit));
    $("#gold>.item-limit").text("可購買次數 "+(shopItem.gold_material.limit - data.player.shop.gold_material)+"/"+(shopItem.gold_material.limit));
    $("#red>.item-limit").text("可購買次數 "+(shopItem.red_material.limit - data.player.shop.red_material)+"/"+(shopItem.red_material.limit));

    $(".shop-buy").attr("disabled",false);
    if(data.player.shop.green_material>=shopItem.green_material.limit){
        $("#buy-green").attr("disabled",true);
    }
    if(data.player.shop.blue_material>=shopItem.blue_material.limit){
        $("#buy-blue").attr("disabled",true);
    }
    if(data.player.shop.purple_material>=shopItem.purple_material.limit){
        $("#buy-purple").attr("disabled",true);
    }
    if(data.player.shop.gold_material>=shopItem.gold_material.limit){
        $("#buy-gold").attr("disabled",true);
    }
    if(data.player.shop.red_material>=shopItem.red_material.limit){
        $("#buy-red").attr("disabled",true);
    }

    $(".shop-item>.tip").remove();
    if(data.guild.level < shopItem.green_material.level){
        $("#buy-green").attr("disabled",true);
        $("#buy-green").after('<div class="tip" id="tip-buy">將在公會等級'+shopItem.green_material.level+'等時解鎖</div>');
    }
    if(data.guild.level < shopItem.blue_material.level){
        $("#buy-blue").attr("disabled",true);
        $("#buy-blue").after('<div class="tip" id="tip-buy">將在公會等級'+shopItem.blue_material.level+'等時解鎖</div>');
    }
    if(data.guild.level < shopItem.purple_material.level){
        $("#buy-purple").attr("disabled",true);
        $("#buy-purple").after('<div class="tip" id="tip-buy">將在公會等級'+shopItem.purple_material.level+'等時解鎖</div>');
    }
    if(data.guild.level < shopItem.gold_material.level){
        $("#buy-gold").attr("disabled",true);
        $("#buy-gold").after('<div class="tip" id="tip-buy">將在公會等級'+shopItem.gold_material.level+'等時解鎖</div>');
    }
    if(data.guild.level < shopItem.red_material.level){
        $("#buy-red").attr("disabled",true);
        $("#buy-red").after('<div class="tip" id="tip-buy">將在公會等級'+shopItem.red_material.level+'等時解鎖</div>');
    }
}

function setupmission(){
    $(".mission-container").remove();
    let buf = '';
    for (let i = 0; i < mission.hard.length; i++) {
        buf = buf + '<div class="mission-container" id="mission-hard-'+i+'">' +
        '<div class="mission-level hard">困難</div>' +
        '<div class="mission-describe">'+mission.hard[i].describe+'</div>' +
        '<div class="mission-progress">'+data.player.mission.hard[i]+'/'+mission.hard[i].amount+'</div>' +
        '<div class="mission-rewards">';
        for(let j = 0; j < mission.hard[i].rewards.length; j++) {
            buf = buf + '<div class="rewards-item" id="item-'+mission.hard[i].rewards[j].name+'">' +
            '<div class="rewards-amount">'+mission.hard[i].rewards[j].amount+'</div>'+
            '<div class="tip">'+mission.hard[i].rewards[j].label+'</div></div>';
        }
        buf = buf + '</div></div>';
    }
    $("#mission-week>div:nth-child(2)").html(buf);

    buf = '';
    for (let i = 0; i < mission.medium.length; i++) {
        buf = buf + '<div class="mission-container" id="mission-medium-'+i+'">' +
        '<div class="mission-level medium">中等</div>' +
        '<div class="mission-describe">'+mission.medium[i].describe+'</div>' +
        '<div class="mission-progress">'+data.player.mission.medium[i]+'/'+mission.medium[i].amount+'</div>' +
        '<div class="mission-rewards">';
        for(let j = 0; j < mission.medium[i].rewards.length; j++) {
            buf = buf + '<div class="rewards-item" id="item-'+mission.medium[i].rewards[j].name+'">' +
            '<div class="rewards-amount">'+mission.medium[i].rewards[j].amount+'</div>'+
            '<div class="tip">'+mission.medium[i].rewards[j].label+'</div></div>';
        }
        buf = buf + '</div></div>';
    }
    for (let i = 0; i < mission.easy.length; i++) {
        buf = buf + '<div class="mission-container" id="mission-easy-'+i+'">' +
        '<div class="mission-handin">繳交</div>' + 
        '<div class="mission-level easy">簡單</div>' +
        '<div class="mission-describe">'+mission.easy[i].describe+'</div>' +
        '<div class="mission-progress">'+data.player.mission.easy[i]+'/'+mission.easy[i].amount+'</div>' +
        '<div class="mission-rewards">';
        for(let j = 0; j < mission.easy[i].rewards.length; j++) {
            buf = buf + '<div class="rewards-item" id="item-'+mission.easy[i].rewards[j].name+'">' +
            '<div class="rewards-amount">'+mission.easy[i].rewards[j].amount+'</div>'+
            '<div class="tip">'+mission.easy[i].rewards[j].label+'</div></div>';
        }
        buf = buf + '</div></div>';
    }
    $("#mission-day>div:nth-child(2)").html(buf);

    for (const key in mission) {
        for (let i = 0; i < mission[key].length; i++) {
            if(data.player.mission[key][i] >= mission[key][i].amount){
                $('#mission-'+key+'-'+i+">.mission-handin").attr("disabled",true);
                $('#mission-'+key+'-'+i+">.mission-handin").text("");
            }
        }
    }
}