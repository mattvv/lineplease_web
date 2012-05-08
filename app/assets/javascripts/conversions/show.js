var updateStatus = function() {
    console.log("updating conversion:" + conversion_id)
    $.ajax({
        type: 'POST',
        url: '/conversions/status',
        data: 'id=' + conversion_id,
        success: function(data){eval(data);}
    });
    setTimeout("updateStatus()",5000)
}