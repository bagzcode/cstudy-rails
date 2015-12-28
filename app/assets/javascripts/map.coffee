window.setMapsRatio = () ->
  width = $("#maps").width()
  winHeight = $(window).height() - 50
  jakartaHeight = winHeight * 0.65
  javaHeight = winHeight * 0.35

  # $("#maps").height(height)
  $("#jakarta").height(jakartaHeight)
  $("#java").height(javaHeight)

$(document).ready ->
  setMapsRatio()

$(window).resize ->
  # setMapsRatio()
