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

window.zoomBehavior = (canvas,projects) ->
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
    .style("background-color", "lightblue")
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
      .style("stroke", "#555")
      .style("fill", "#f1f1f1")
      .style("stroke-width", "0.1")
      .on("mouseover", ()->
        areas.style("fill", "#f1f1f1")
        d3.select(this).style("fill", "#e9e9e9")
      )
      .on("mouseout", () ->
        areas.style("fill", "#f1f1f1")
      )
    zoomBehavior(window.jakartaCanvas, window.jakartaProjection)
    loadCollectorYards()

window.loadJavaMap = (width,winHeight,javaHeight) ->
  # Initialize canvas for java map
  javaCanvas = d3.select("#java").append("svg")
    .attr("width", width)
    .attr("height", javaHeight)
    .style("background-color", "#f1f1f1")
    .attr("cursor", "grab")

  # Load json data from jakarta.json
  # Build java map
  d3.json "/map/java.json", (java) ->
    # console.log java.features
    # $.each(java.features, (i,v) ->
    #   console.log v.properties.ID
    # )

    group = javaCanvas.selectAll("g.dis")
      .data(java.features)
      .enter()
      .append("g")
      .attr("class", "dis")

    areas = group.append("path")
      .attr("d", window.javaPath)
      .attr("class", "java-area")
      .style("stroke", "#555")
      .style("fill", "#ddd")
      .style("stroke-width", "0.1")
      .on('click', (d) ->
        console.log d.properties.KAB_KOTA
        areas.style("fill", "#ddd")
        d3.select(this).style("fill", "#f00")
      )

    zoomBehavior(javaCanvas, window.javaProjection)

window.updateCollectorYards = () ->
  window.jakartaCanvas.selectAll(".collector-yards")
    .attr("fill", (d) ->
      if isSelected({code: d3.select(this).attr("code")})
        d3.select(this).attr("fill")
      else
        "#f0f0f0"
    )

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
        .on("click", onClick)

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
