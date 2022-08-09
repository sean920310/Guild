class ConfirmBox {
    constructor(text,yesCallBack,noCallBack){
        this.text = text;
        this.nowOpen = false;
        this.yesCallBack = yesCallBack;
        this.noCallBack = noCallBack;
    }
    
    static isOpen = false;

    open(){
        $("#confirm-text").text(this.text)
        $("#confirmWindow").show();
        ConfirmBox.isOpen = true;
        this.nowOpen = true;
    }

    yes(){
        this.yesCallBack();
        $("#confirmWindow").hide();
        ConfirmBox.isOpen = false;
        this.nowOpen = false;
    }

    no(){
        this.noCallBack();
        $("#confirmWindow").hide();
        ConfirmBox.isOpen = false;
        this.nowOpen = false;
    }
}