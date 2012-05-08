width = 0
var updateStatus = function() {
    $.ajax({
        type: 'POST',
        url: '/conversions/status',
        data: 'id=' + conversion_id,
        success: function(data){eval(data);}
    });

    if (width < 100) {
       setTimeout("updateStatus()",5000);
    }
}