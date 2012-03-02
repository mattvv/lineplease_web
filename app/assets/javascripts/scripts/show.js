$(document).ready(function() {
  $('.tabs').button();

  $('#back-to-scripts').click(function () {
    console.log("clicked scripts");
    location.href = "/scripts";
    return false;
  });

  $('.gender').click(function() {
     return false;
  });
});