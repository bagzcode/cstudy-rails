# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.sizing = (vol) ->
  small = new Array(90)
  i=0
  while i < small.length
    if (i+1) is parseInt(vol)
      return 4
    else
      return 7
    i++

window.cyFiltered = (data_filtered) ->
  d3.selectAll(".collector-yards").remove()
  d3.csv "/map/collector_yards.csv", (result) ->
    for r in result
      for data in data_filtered
        if r.code is data.origin_code
          # console.log r
          window.jakartaCanvas.append("circle")
            # .attr("r", window.sizing(data.weekly_volume))
            .attr("r", 5)
            .attr("cx", window.jakartaProjection([r.X, r.Y])[0] )
            .attr("cy", window.jakartaProjection([r.X, r.Y])[1] )
            .attr("code", r.code)
            .attr("type", r.type)
            .style("fill", "red")
            .style("opacity", 0.5)
            .attr("class", "collector-yards")