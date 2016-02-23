movementTypes = [
  {"id":1, "title":"LC", "label":"LC", "shape":"rect", "color":"aqua"},
  {"id":2, "title":"FA", "label":"FA", "shape":"circle", "color":"darkcyan"},
  {"id":3, "title":"Br", "label":"Br", "shape":"rect", "color":"blue"},
  {"id":4, "title":"CY", "label":"CY", "shape":"rect", "color":"green"},
  {"id":5, "title":"blank", "label":"", "shape":"circle", "color":"black"},
  {"id":6, "title":"LBM", "label":"LBM", "shape":"circle", "color":"red"},
  {"id":7, "title":"AS", "label":"AS", "shape":"circle", "color":"purple"},
  {"id":8, "title":"AB", "label":"AB", "shape":"rect", "color":"yellow"}
]
setRect = []
activeFilteredCy = null

window.setFilteredCyToDefault = () ->
  d3.selectAll(".movements-filtered").each (d) ->
    resetFilteredCy(d3.select(this))

window.clearResult = () ->
  d3.selectAll(".movements-movement-out").remove()
  d3.selectAll(".connector-line").remove()
  d3.select("#line_canvas").html("")
  d3.selectAll(".center-dot-district").remove()
  d3.selectAll(".java-area").style("fill", "#e9e5dc")

window.setSideHeight = () ->
  target = $("#results")
  target.height(window.screenHeight-70)
  target.css("overflow","auto")

window.movementLegend = () ->
  canvas = window.jakartaCanvas.append("g")
  x = 15
  y = 400
  canvas.append("text")
    .text("LEGEND:")
    .attr("dx", x)
    .attr("dy", y+10)
    .style("font-weight", 600)
  for mt in movementTypes
    if mt.shape is "rect"
      y+=20
      canvas.append("rect")
        .attr("x", x)
        .attr("y", y)
        .attr("width", window.rectSize)
        .attr("height", window.rectSize)
        .style("fill", mt.color)
      canvas.append("text")
        .text(mt.title)
        .attr("dx", x+15)
        .attr("dy", y+10)
    if mt.shape is "circle"
      y+=20
      canvas.append("circle")
        .attr("cx", x+5)
        .attr("cy", y+5)
        .attr("r", 5)
        .style("fill", mt.color)
      canvas.append("text")
        .text(mt.title)
        .attr("dx", x+15)
        .attr("dy", y+10)

window.loadAllMovementOuts = () ->
  for mt in movementTypes
    if mt.shape is "rect"
      setRect.push mt.label

  d3.csv "/map/movement_out.csv", (result) ->
    for mo in result
      coordinate = window.jakartaProjection([mo.origin_x, mo.origin_y])
      if $.inArray(mo.type_destination, setRect) isnt -1
        window.jakartaCanvas.append("rect")
          .attr("x", coordinate[0])
          .attr("y", coordinate[1])
          .attr("org_code", mo.origin_code)
          .attr("type", mo.type_destination)
          .attr("width", window.rectSize)
          .attr("height", window.rectSize)
          .style("fill", colored(mo))
          .style("opacity", 0.5)
          .attr("class", "movements")
      else
        window.jakartaCanvas.append("circle")
          .attr("r", 5)
          .attr("cx", coordinate[0])
          .attr("cy", coordinate[1])
          .attr("org_code", mo.origin_code)
          .attr("type", mo.type_destination)
          .style("fill", colored(mo))
          .style("opacity", 0.5)
          .attr("class", "movements")
  movementLegend()

window.cyFiltered = (data_filtered) ->
  d3.csv "/map/movement_out.csv", (result) ->
    window.movementOut = result
    
  d3.csv "/map/movement_in.csv", (result) ->
    window.movementIn = result

  d3.selectAll(".movements").attr("class", "movements hidden")
  for data in data_filtered
    d3.selectAll(".movements").each (d) ->
      if data.origin_code is d3.select(this).attr("org_code")
        d3.select(this).attr("class", "movements movements-filtered")
        d3.select(this).attr("des_code", data.destination_code)

colored = (data) ->
  for mt in movementTypes
    if mt.label is data.type_destination
      return mt.color

connectFromOriginToCyFiltered = (dataMi,x,y,canvas) ->
  d3.selectAll(".java-area").each (d) ->
    if d.properties.KAB_KOTA is dataMi.origin_district
      dot = window.javaCanvas.append("circle")
        .attr("class", "center-dot-district")
        .attr("cx", window.javaPath.centroid(d)[0])
        .attr("cy", window.javaPath.centroid(d)[1])
        .attr("r", 0)
      d3.select(this).style("fill", "#428bca")
      dotX = dot.node().getBoundingClientRect().left-12
      dotY = dot.node().getBoundingClientRect().top
      origin = [dotX, dotY]
      destination = [x, y]
      drawConnectorLine(origin, destination, canvas, dataMi.destination_code)

resetFilteredCy = (me) ->
  if $.inArray(me.attr("type"), setRect) isnt -1
    me.attr("width", window.rectSize)
    me.attr("height", window.rectSize)
  else
    me.attr("r", 5)

selectFilteredCy = (me) ->
  if $.inArray(me.attr("type"), setRect) isnt -1
    me.attr("width", window.rectSize+4)
    me.attr("height", window.rectSize+4)
    a = parseInt(me.attr("x"))+7
    b = parseInt(me.attr("y"))+7
  else
    me.attr("r", 7)
    a = parseInt(me.attr("cx"))
    b = parseInt(me.attr("cy"))
  return [a,b]

showDetailResult = (code) ->
  d3.selectAll(".movements-filtered").each (d) ->
    resetFilteredCy(d3.select(this))
    if d3.select(this).attr("org_code") is code
      clearResult()
      origin = selectFilteredCy(d3.select(this))
      origin_c = d3.select(this).attr("org_code")
      for mo in window.movementOut
        if mo.origin_code is d3.select(this).attr("org_code")
          coordinate = window.jakartaProjection([mo.destination_x_original, mo.destination_y_original])
          if $.inArray(mo.type_destination, setRect) isnt -1
            window.jakartaCanvas.append("rect")
              .attr("x", coordinate[0])
              .attr("y", coordinate[1])
              .attr("org_code", mo.origin_code)
              .attr("type", mo.type_destination)
              .attr("width", window.rectSize)
              .attr("height", window.rectSize)
              .style("fill", colored(mo))
              .style("opacity", 0.5)
              .attr("class", "movements-movement-out")
            destination = [coordinate[0]+(window.rectSize/2), coordinate[1]+(window.rectSize/2)]
          else
            window.jakartaCanvas.append("circle")
              .attr("r", 5)
              .attr("cx", coordinate[0])
              .attr("cy", coordinate[1])
              .attr("org_code", mo.origin_code)
              .attr("type", mo.type_destination)
              .style("fill", colored(mo))
              .style("opacity", 0.5)
              .attr("class", "movements-movement-out")
            destination = [coordinate[0], coordinate[1]]

          drawConnectorLine(origin, destination, window.jakartaCanvas, origin_c)

      lineCanvas = d3.select("#line_canvas").append("svg")
        .attr("height", $(window).height()-50)
        .attr("width", $("#maps").width())
      for mi in window.movementIn
        if mi.destination_code is d3.select(this).attr("org_code")
          connectFromOriginToCyFiltered(mi,origin[0],origin[1],lineCanvas)

ready = ->
  $("body").on "click", ".link-show-on-map", (e) ->
    e.preventDefault()
    $this = $(this)
    code = $this.attr "href"
    showDetailResult(code)

$(document).ready ready
$(document).on 'page:load', ready