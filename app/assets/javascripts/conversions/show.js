width = 0
var updateStatus = function() {
    console.log("updating conversion:" + conversion_id)
    $.ajax({
        type: 'POST',
        url: '/conversions/status',
        data: 'id=' + conversion_id,
        success: function(data){eval(data);}
    });

    console.log('width: ' + width)
    if (width < 100) {
       setTimeout("updateStatus()",5000);
    }
}