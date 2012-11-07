$(document).ready(function() {
  // forms

  // -- replace select menus with html dropdown menu
  // -- be sure to include jquery.selectbox-0.5.js
  $('form select').selectbox();
  // -- add classes to form fields
  $('html body textarea, html body input[type="text"], html body input[type="password"]').addClass("text");
  $('input[type="submit"]').addClass("submit");
  // -- wrap error fields with error div
  $("form .fieldWithErrors").closest("div.field").addClass("error")
  // -- add active class to active elements
  $("form select, form .text").focus(function( ){
    $(this).closest("div.field").addClass("active");
    $(this).closest("fieldset").addClass("active");
  });
  // -- remove active class from inactive elements
  $("form select, form .text").blur(function( ){
    $(this).closest("div.field").removeClass("active");
    $(this).closest("fieldset").removeClass("active");
  });
  // -- make error notice the same width as error field
  $("form .fieldWithErrors input").each(function(i, field){
    width = $(field).width();
    $(field).closest('div.field').find('.formError').width(width);
  });
	// make main #flash notice same width as next panel or content
  width = $("#flash").next().children(".panel").width();
  $("#flash").width(width);
});