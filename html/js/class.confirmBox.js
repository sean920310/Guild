function ConfirmBox(data) {
    //open
    $("#confirm-text").text(data.text)
    $("#confirmWindow").show();
    data.isOpen = true;
    

    //yes
    $("#confirm-button-yes").on("click",function() {
        data.yesCallBack();
        $("#confirmWindow").hide();
        data.isOpen = false;
        $("#confirm-button-yes").off();
        $("#confirm-button-no").off();
    });
    
    //no
    $("#confirm-button-no").on("click",function() {
        data.noCallBack();
        $("#confirmWindow").hide();
        data.isOpen = false;
        $("#confirm-button-yes").off();
        $("#confirm-button-no").off();
    });
}