isRect = [
  {"id":1, "label":"LC"},
  {"id":3, "label":"Br"},
  {"id":4, "label":"CY"},
  {"id":8, "label":"AB"}
]
# isCircle = [
#   {"id":2, "label":"FA"},
#   {"id":5, "label":"blank"},
#   {"id":6, "label":"LBM"},
#   {"id":7, "label":"AS"}
# ]
forRectId = []
forRectLabel = []

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

window.colored = (data,type) ->
  if type is "id"
    types = [
      {"id":1, "color":"aqua"},
      {"id":2, "color":"purple"},
      {"id":3, "color":"blue"},
      {"id":4, "color":"green"},
      {"id":5, "color":"black"},
      {"id":6, "color":"red"},
      {"id":7, "color":"darkcyan"},
      {"id":8, "color":"yellow"}
    ]
    for t in types
      if t.id is data.collector_type_id
        return t.color
  else
    types = [
      {"label":"LC", "color":"aqua"},
      {"label":"FA", "color":"purple"},
      {"label":"Br", "color":"blue"},
      {"label":"CY", "color":"green"},
      {"label":"", "color":"black"},
      {"label":"LBM", "color":"red"},
      {"label":"AS", "color":"darkcyan"},
      {"label":"AB", "color":"yellow"}
    ]
    for t in types
      if t.label is data.type_destination
        return t.color

window.cyFiltered = (data_filtered) ->
  d3.selectAll(".movements").attr("class", "movements hidden")
  for ir in isRect
    forRectId.push(ir.id)
    forRectLabel.push(ir.label)
  for data in data_filtered
    console.log data.collector_type_id
    d3.selectAll(".movements").each (d) ->
      if data.origin_code is d3.select(this).attr("org_code")
        d3.select(this).attr("class", "movements movements-filtered")
        d3.select(this).attr("des_code", data.destination_code)

window.connectFromOriginToCyFiltered = (dataMi,x,y,canvas) ->
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

window.loadAllMovementOuts = () ->
  setRect = ["LC","Br","CY","AB"]
  for mo in window.movementOut
    coordinate = window.jakartaProjection([mo.origin_x, mo.origin_y])
    if $.inArray(mo.type_destination, setRect) isnt -1
      window.jakartaCanvas.append("rect")
        .attr("x", coordinate[0])
        .attr("y", coordinate[1])
        .attr("org_code", mo.origin_code)
        .attr("type", mo.type_destination)
        .attr("width", window.rectSize)
        .attr("height", window.rectSize)
        .style("fill", colored(mo,"label"))
        .style("opacity", 0.5)
        .attr("class", "movements")
    else
      window.jakartaCanvas.append("circle")
        .attr("r", 5)
        .attr("cx", coordinate[0])
        .attr("cy", coordinate[1])
        .attr("org_code", mo.origin_code)
        .attr("type", mo.type_destination)
        .style("fill", colored(mo,"label"))
        .style("opacity", 0.5)
        .attr("class", "movements")

resetFilteredCy = (me) ->
  if $.inArray(me.attr("type"), forRectLabel) isnt -1
    me.attr("width", window.rectSize)
    me.attr("height", window.rectSize)
  else
    me.attr("r", 5)

selectFilteredCy = (me) ->
  if $.inArray(me.attr("type"), forRectLabel) isnt -1
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
          if $.inArray(mo.type_destination, forRectLabel) isnt -1
            window.jakartaCanvas.append("rect")
              .attr("x", coordinate[0])
              .attr("y", coordinate[1])
              .attr("org_code", mo.origin_code)
              .attr("type", mo.type_destination)
              .attr("width", window.rectSize)
              .attr("height", window.rectSize)
              .style("fill", colored(mo,"label"))
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
              .style("fill", colored(mo,"label"))
              .style("opacity", 0.5)
              .attr("class", "movements-movement-out")
            destination = [coordinate[0], coordinate[1]]

          drawConnectorLine(origin, destination, window.jakartaCanvas, origin_c)

      lineCanvas = d3.select("#line_canvas").append("svg")
        .attr("height", $(window).height() - 50)
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
$(document).on('page:load', ready);