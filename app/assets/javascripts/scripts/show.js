//= require pakunok/jquery-ui/pack/sortable

$(document).ready(function() {
  $('.tabs').button();

  $('#back-to-scripts').click(function () {
    console.log("clicked scripts");
    location.href = "/scripts";
    return false;
  });

    $('#lines').sortable({
      stop: function(event, ui) {
        var line_id = $(ui.item).attr('id')
        var position = ui.item.prevAll().length;
        $.post('/lines/update_position', {
          'line_id': line_id,
          'position': position
         });
      }
    });
  $( "#lines" ).disableSelection();
});