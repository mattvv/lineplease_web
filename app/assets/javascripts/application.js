// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//= require jquery
//= require jquery_ujs
//= require jquery_faded
//= require twitter/bootstrap
//= require facebook
//= require mobilecheck
//= require_tree .

$(document).ready(function() {
    $('.dropdown-toggle').dropdown();
    $(".alert").alert();
    $('#female').click(function() {
        $('#genderField').val("female");
        $('#female').addClass("active");
        $('#male').removeClass("active");
        return false;
    });
    $('#male').click(function() {
        $('#genderField').val("male");
        $('#male').addClass("active");
        $('#female').removeClass("active");
        return false;
    });
});
