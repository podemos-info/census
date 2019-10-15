document.addEventListener("DOMContentLoaded", () => {
  if ($(".current_filter").length>0) $("body").addClass("with_filters");

  $("#searchinput").on('keyup keypress blur change', function(){
    var original_value = $(this).data("value") || "";
    $(this).toggleClass("changed", $(this).val()!=original_value);
  })
});
