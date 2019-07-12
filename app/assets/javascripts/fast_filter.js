$(document).ready(function(){
  $("#searchinput").on('keyup keypress blur change', function(){
    var original_value = $(this).data("value") || "";
    $(this).toggleClass("changed", $(this).val()!=original_value);
  })
});
