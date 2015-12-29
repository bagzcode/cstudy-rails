window.jakartaCanvas = null
window.javaCanvas = null

window.jakartaProjection = null
window.jakartaPath = null

window.javaProjection = null
window.javaPath = null

window.collectorYards = null
window.movementIn = null
window.movementOut = null
window.circleRadius = 5;
window.rectSize = 10;

window.selectedCode = null;
window.destinations = [];

window.setMapsRatio = (winHeight,jakartaHeight,javaHeight) ->
  # $("#maps").height(height)
  $("#jakarta").height(jakartaHeight)
  $("#java").height(javaHeight)

window.zoomBehavior = (canvas) ->
  zoom = d3.behavior.zoom()
  .on("zoom", () ->
    canvas.selectAll(".dis")
      .attr("transform", "translate("+d3.event.translate.join(",")+")scale("+d3.event.scale+")")
    canvas.selectAll("circle.collector-yards")
      .attr("transform", "translate("+d3.event.translate.join(",")+")scale("+d3.event.scale+")")
      .attr("r", window.circleRadius/d3.event.scale)
    canvas.selectAll("rect.collector-yards")
      .attr("transform", "translate("+d3.event.translate.join(",")+")scale("+d3.event.scale+")")
      .attr("width", window.rectSize/d3.event.scale)
      .attr("height", window.rectSize/d3.event.scale)
  )
  canvas.call(zoom).on("dblclick.zoom", null)

window.loadJakartaMap = (width,winHeight,jakartaHeight) ->
  # Initialize canvas for jakarta map
  window.jakartaCanvas = d3.select("#jakarta").append("svg")
    .attr("width", width)
    .attr("height", jakartaHeight)
    .style("background-color", "#ddd")
    .attr("cursor", "grab")

  # Load json data from jakarta.json
  # Build jakarta map
  d3.json "/map/jakarta.json", (jkt) ->
    group = window.jakartaCanvas.selectAll("g.dis")
      .data(jkt.features)
      .enter()
      .append("g")
      .attr("class", "dis")

    areas = group.append("path")
      .attr("d", window.jakartaPath)
      .attr("class", "area")
      .style("stroke", "#eee")
      .style("stroke-width", "0.5")
      .style("fill", "#bbb")
      .on "mouseover", ()->
        areas.style("fill", "#bbb")
        d3.select(this).style("fill", "#aaa")
      .on "mouseout", () ->
        areas.style("fill", "#bbb")

    zoomBehavior(window.jakartaCanvas)
    loadCollectorYards()

window.loadJavaMap = (width,winHeight,javaHeight) ->
  # Initialize canvas for java map
  javaCanvas = d3.select("#java").append("svg")
    .attr("width", width)
    .attr("height", javaHeight)
    .style("background-color", "#74ADC0")
    .attr("cursor", "grab")

  # Load json data from jakarta.json
  # Build java map
  d3.json "/map/java.json", (java) ->
    group = javaCanvas.selectAll("g.dis")
      .data(java.features)
      .enter()
      .append("g")
      .attr("class", "dis")

    areas = group.append("path")
      .attr("d", window.javaPath)
      .attr("class", "java-area")
      .style("stroke", "#999")
      .style("stroke-width", "5px")
      .style("fill", "#e9e5dc")
      .style("stroke-width", "0.1")
      .on "mouseover", () ->
        d3.select(this).attr("cursor", "pointer")
      .on "click", (d) ->
        areas.style("fill", "#e9e5dc")
        d3.select(this).style("fill", "#428bca")
        connectToJakarta(d.properties.KAB_KOTA)

    zoomBehavior(javaCanvas)

window.updateCollectorYards = () ->
  window.jakartaCanvas.selectAll(".collector-yards")
    .attr("fill", (d) ->
      if isSelected({code: d3.select(this).attr("code")})
        d3.select(this).attr("fill")
      else
        "#f0f0f0"
    )

# Nano
# window.updateCollectorYards = () ->
#   collectorYardsAll = $(".collector-yards")
#   for cya in collectorYardsAll
#     if isSelected({code: d3.select(cya).attr("code")})
#       d3.select(cya).attr("class", "collector-yards")
#     else
#       d3.select(cya).attr("class", "hidden")

window.findDestination = (code) ->
  result = []
  for mo in window.movementOut
    if mo.origin_code is code
      result.push(mo)
  # console.log result
  result

window.isSelected = (d) ->
  # console.log("DEST", window.destinations)
  # console.log("LEN", window.destinations.length)
  if window.destinations.length is 0
    return true
  for destination in window.destinations
    console.log("isSelected", d.code is destination.destination_LBM_CY_id)
    if d.code is destination.destination_LBM_CY_id
      return true
  return false

window.loadCollectorYards = () ->
  onClick = () ->
    window.selectedCode = d3.select(this).attr("code")
    window.destinations = findDestination(window.selectedCode)
    updateCollectorYards()

  window.jakartaCanvas.selectAll("circle.collector-yards")
    .data(window.collectorYards)
    .enter()
    .append("circle")
    .filter((d) -> d.type is "LBM")
    .attr("r", circleRadius)
    .attr("cx", (d) -> window.jakartaProjection([d.X, d.Y])[0] )
    .attr("cy", (d) -> window.jakartaProjection([d.X, d.Y])[1] )
    .attr("code", (d,i) -> d.code)
    .attr("fill", "red")
    .attr("class", "collector-yards")
    .on("mouseover", () ->
      d3.select(this).attr("cursor", "pointer")
    )
    .on("click", onClick)

  window.jakartaCanvas.selectAll("rect.collector-yards")
    .data(window.collectorYards)
    .enter()
    .append("rect")
    .filter((d) -> d.type is "CY")
    .attr("x", (d) -> window.jakartaProjection([d.X, d.Y])[0] )
    .attr("y", (d) -> window.jakartaProjection([d.X, d.Y])[1] )
    .attr("code", (d,i) -> d.code)
    .attr("width", rectSize)
    .attr("height", rectSize)
    .attr("fill", "green")
    .attr("class", "collector-yards")
    .on("mouseover", () ->
      d3.select(this).attr("cursor", "pointer")
    )
    .on("click", onClick)

window.connectToJakarta = (district_code) ->
  $(".collector-yards").attr("class", "collector-yards hidden")
  for mi in window.movementIn
    if mi.origin_district is district_code
      collectorYardsCode = $(".collector-yards")
      for cyc in collectorYardsCode
        if d3.select(cyc).attr("code") is mi.destination_code
          d3.select(cyc).attr("class", "collector-yards")
          d3.select(cyc).style("fill", "#428bca")

$(document).ready ->
  # Global variabel
  width = $("#maps").width()
  winHeight = $(window).height() - 50
  jakartaHeight = winHeight * 0.65
  javaHeight = winHeight * 0.35

  d3.csv "/map/movement_in.csv", (result) ->
    window.movementIn = result

  d3.csv "/map/movement_out.csv", (result) ->
    window.movementOut = result

  d3.csv "/map/collector_yards.csv", (collectorYards) ->
    window.collectorYards = collectorYards

    window.jakartaProjection = d3.geo.mercator().rotate([-105.88,5.87,0]).scale(width*30).translate([0, 0])
    window.jakartaPath = d3.geo.path().projection(window.jakartaProjection)

    window.javaProjection = d3.geo.mercator().rotate([-105,5.80,0]).scale(width*5).translate([0, 0])
    window.javaPath = d3.geo.path().projection(window.javaProjection)

    setMapsRatio(winHeight,jakartaHeight,javaHeight)
    loadJakartaMap(width,winHeight,jakartaHeight)
    loadJavaMap(width,winHeight,javaHeight)

$(window).resize ->
  # setMapsRatio()
