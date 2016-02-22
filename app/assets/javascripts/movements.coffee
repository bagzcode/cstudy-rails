window.setSideHeight = () ->
  target = $("#results")
  target.height(window.screenHeight-70)
  target.css("overflow","auto")

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
          window.jakartaCanvas.append("circle")
              # .attr("r", window.sizing(data.weekly_volume))
              .attr("r", 5)
              .attr("cx", window.jakartaProjection([r.X, r.Y])[0] )
              .attr("cy", window.jakartaProjection([r.X, r.Y])[1] )
              .attr("code", r.code)
              .attr("type", r.type)
              .style("fill", "red")
              .style("opacity", 0.5)
              .attr("class", "collector-yards collector-yards-filtered")

window.filled = (data) ->
  if data.type_destination is "CY"
    "green"
  else if data.type_destination is "LBM"
    "red"
  else if data.type_destination is "AS"
    "blue"
  else
    "yellow"

window.titelize = (data) ->
  label = []
  if data.destination_lbm_cy_id isnt ""
      label.push(data.destination_lbm_cy_id)
  if data.destination_sub_district isnt ""
      label.push(data.destination_sub_district)
  if data.destination_district isnt ""
      label.push(data.destination_district)
  
  if label.length is 0
    return "N/A"
  else
    return label.join(", ")

window.connectFromOriginToCyFiltered = (dataMi,x,y,canvas) ->
  d3.selectAll(".java-area").each (d) ->
    if d.properties.KAB_KOTA is dataMi.origin_district
      dot = window.javaCanvas.append("circle")
        .attr("class", "center-dot-district")
        .attr("cx", window.javaPath.centroid(d)[0])
        .attr("cy", window.javaPath.centroid(d)[1])
        .attr("r", 0)
      d3.select(this).style("fill", "#428bca")
      dotX = dot.node().getBoundingClientRect().x-12
      dotY = dot.node().getBoundingClientRect().y
      origin = [dotX, dotY]
      destination = [x, y]
      drawConnectorLine(origin, destination, canvas, dataMi.destination_code)


ready = ->
  $("body").on "click", ".link-show-on-map", (e) ->
    e.preventDefault()
    $this = $(this)
    code = $this.attr "href"
    d3.selectAll(".collector-yards-filtered").each (d) ->
      d3.select(this).style("fill", "red")
      d3.select(this).attr("r", 5)
      if d3.select(this).attr("code") is code
        d3.selectAll(".collector-yards-movement-out").remove()
        d3.selectAll(".connector-line").remove()
        d3.select("#line_canvas").html("")

        d3.select(this).style("fill", "green")
        d3.select(this).attr("r", 7)
        origin_a = parseInt(d3.select(this).attr("cx"))
        origin_b = parseInt(d3.select(this).attr("cy"))
        origin_c = d3.select(this).attr("code")
        for mo in window.movementOut
          if mo.origin_code is d3.select(this).attr("code")
            coordinate = window.jakartaProjection([mo.destination_x_original, mo.destination_y_original])
            window.jakartaCanvas.append("rect")
              .attr("x", coordinate[0])
              .attr("y", coordinate[1])
              .attr("code", mo.origin_code)
              .attr("type", mo.type_destination)
              .attr("title", window.titelize(mo))
              .attr("width", window.rectSize)
              .attr("height", window.rectSize)
              .style("fill", "#428bca")
              .style("opacity", 0.5)
              .attr("class", "collector-yards-movement-out")

            destination = [coordinate[0]+(window.rectSize/2), coordinate[1]+(window.rectSize/2)]
            origin = [origin_a, origin_b]

            drawConnectorLine(origin, destination, window.jakartaCanvas, origin_c)

        d3.selectAll(".java-area").style("fill", "#e9e5dc")
        d3.selectAll(".center-dot-district").remove()
        lineCanvas = d3.select("#line_canvas").append("svg")
          .attr("height", $(window).height() - 50)
          .attr("width", $("#maps").width())
        for mi in window.movementIn
          if mi.destination_code is d3.select(this).attr("code")
            connectFromOriginToCyFiltered(mi,origin_a,origin_b,lineCanvas)

$(document).ready ready
$(document).on('page:load', ready);