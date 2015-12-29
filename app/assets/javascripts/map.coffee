window.setMapsRatio = (winHeight,jakartaHeight,javaHeight) ->
  # $("#maps").height(height)
  $("#jakarta").height(jakartaHeight)
  $("#java").height(javaHeight)

window.zoomBehavior = (canvas,projects) ->
  zoom = d3.behavior.zoom()
  .on("zoom", () ->
    canvas.selectAll(".dis")
      .attr("transform", "translate("+d3.event.translate.join(",")+")scale("+d3.event.scale+")")
  )
  canvas.call(zoom).on("dblclick.zoom", null)

window.loadJakartaMap = (width,winHeight,jakartaHeight) ->
  # Initialize canvas for jakarta map
  canvas = d3.select("#jakarta").append("svg")
    .attr("width", width)
    .attr("height", jakartaHeight)
    .style("background-color", "lightblue")
    .attr("cursor", "grab")

  # Load json data from jakarta.json
  # Build jakarta map
  d3.json "/map/jakarta.json", (jkt) ->
    group = canvas.selectAll("g.dis")
      .data(jkt.features)
      .enter()
      .append("g")
      .attr("class", "dis")
    projection = d3.geo.mercator().rotate([-105.88,5.87,0]).scale(width*30).translate([0, 0])
    path = d3.geo.path().projection(projection)

    areas = group.append("path")
      .attr("d", path)
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
    zoomBehavior(canvas,projection)

window.loadJavaMap = (width,winHeight,javaHeight) ->
  # Initialize canvas for java map
  canvas = d3.select("#java").append("svg")
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

    group = canvas.selectAll("g.dis")
      .data(java.features)
      .enter()
      .append("g")
      .attr("class", "dis")
    projection = d3.geo.mercator().rotate([-105,5.80,0]).scale(width*5).translate([0, 0])
    path = d3.geo.path().projection(projection)

    areas = group.append("path")
      .attr("d", path)
      .attr("class", "java-area")
      .style("stroke", "#555")
      .style("fill", "#ddd")
      .style("stroke-width", "0.1")
      .on('click', (d) ->
        console.log d.properties.KAB_KOTA
        areas.style("fill", "#ddd")
        d3.select(this).style("fill", "#f00")
      )

    zoomBehavior(canvas,projection)

$(document).ready ->
  # Global variabel
  width = $("#maps").width()
  winHeight = $(window).height() - 50
  jakartaHeight = winHeight * 0.65
  javaHeight = winHeight * 0.35

  setMapsRatio(winHeight,jakartaHeight,javaHeight)
  loadJakartaMap(width,winHeight,jakartaHeight)
  loadJavaMap(width,winHeight,javaHeight)

$(window).resize ->
  # setMapsRatio()
