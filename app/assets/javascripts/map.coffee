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
window.origins = [];

window.setMapsRatio = (winHeight,jakartaHeight,javaHeight) ->
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
    canvas.selectAll("line.connector-line")
      .attr("transform", "translate("+d3.event.translate.join(",")+")scale("+d3.event.scale+")")
  )
  canvas.call(zoom).on("dblclick.zoom", null)

window.loadJabodetabekMap = (width,winHeight,jakartaHeight) ->
  window.jakartaCanvas = d3.select("#jakarta").append("svg")
    .attr("width", width)
    .attr("height", jakartaHeight)
    .style("background-color", "#ddd")

  d3.json "/map/jakarta.json", (jkt) ->
    group = window.jakartaCanvas.selectAll("g.dis")
      .data(jkt.features)
      .enter()
      .append("g")
      .attr("class", "dis")

    areas = group.append("path")
      .attr("d", window.jakartaPath)
      .attr("class", "jabodetabek-area")
      .attr("district", (d) -> d.properties.KAB_KOTA)
      .style("stroke", "#eee")
      .style("stroke-width", "0.5")
      .style("fill", "#bbb")
      .on "mouseover", (d)->
        d3.select(this).attr("title", d.properties.KAB_KOTA)

    # Panggil fungsi untuk menampilkan titik CY/LBM di peta Jabodetabek
    loadCollectorYards()

# Fungsi untuk menampilkan peta pulau jawa
# Fungsi ini dipanggil saat document ready
window.loadJavaMap = (width,winHeight,javaHeight) ->
  window.javaCanvas = d3.select("#java").append("svg")
    .attr("width", width)
    .attr("height", javaHeight)
    .style("background-color", "#74ADC0")

  d3.json "/map/java.json", (java) ->
    group = window.javaCanvas.selectAll("g.dis")
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
      .attr("district", (d) -> d.properties.KAB_KOTA)
      .on "mouseover", (d) ->
        d3.select(this)
          .attr("title", d.properties.KAB_KOTA)

window.loadCollectorYards = () ->
  d3.csv "/map/collector_yards.csv", (result) ->
    window.jakartaCanvas.selectAll("circle.collector-yards")
      .data(result)
      .enter()
      .append("circle")
      .filter((d) -> d.type is "LBM")
      .attr("r", circleRadius)
      .attr("cx", (d) -> window.jakartaProjection([d.X, d.Y])[0] )
      .attr("cy", (d) -> window.jakartaProjection([d.X, d.Y])[1] )
      .attr("code", (d) -> d.code)
      .attr("type", (d) -> d.type)
      .style("fill", "red")
      .style("opacity", 0.5)
      .attr("class", "collector-yards")

    window.jakartaCanvas.selectAll("rect.collector-yards")
      .data(result)
      .enter()
      .append("rect")
      .filter((d) -> d.type is "CY")
      .attr("x", (d) -> window.jakartaProjection([d.X, d.Y])[0] )
      .attr("y", (d) -> window.jakartaProjection([d.X, d.Y])[1] )
      .attr("code", (d) -> d.code)
      .attr("type", (d) -> d.type)
      .attr("width", rectSize)
      .attr("height", rectSize)
      .style("fill", "green")
      .style("opacity", 0.5)
      .attr("class", "collector-yards")

window.loadSubDistrict = () ->
  # fungsi untuk load sub district

window.jabodetabekPointDistrict = (d) ->
  # Untuk menambahkan element "g" yang akan meng-group circle di pusat District peta Jabodetabek yang di append di window.jakartaCanvas
  districtDot = window.jakartaCanvas.append("g")
    .attr("class", "dot-district-jabodetabek")

  # Menambahkan circle di pusat District peta Jabodetabek
  districtDot.append("circle")
    .attr("cx", window.jakartaPath.centroid(d)[0])
    .attr("cy", window.jakartaPath.centroid(d)[1])
    .attr("r", 5)
    .attr("fill", "#00F")
  return districtDot

window.findDestination = (code) ->
  result = []
  for mo in window.movementOut
    if mo.origin_code is code
      result.push(mo)
  return result

# Fungsi untuk membuat line atau garis
# Parameters:
# - x: array of coordinate x
# - y: array of coordinate y
# - canvas: canvas tempat line akan di-append
# - data: berupa string, untuk memberikan kode destinasi pada masing2 garis
window.drawConnectorLine = (x,y,canvas,data) ->
  line = canvas.append("line")
    .attr("class", "connector-line")
    .attr("code", data)
    .attr("x1", x[0])
    .attr("x2", x[0])
    .attr("y1", x[1])
    .attr("y2", x[1])
    .style("stroke", "#444")
    .style("opacity", 0.5)
    .transition()
      .duration(800)
      .ease("linear")
      .attr({x2: y[0], y2: y[1]})

# Fungsi untuk men-transform Origin District ke posisi tengah dari canvas peta Jawa saat district tersebut di pilih
# source http://bl.ocks.org/mbostock/2206529
window.centralizeSelectedArea = (canvas, path, data) ->
  width = d3.select(canvas.node()).attr("width")
  height = d3.select(canvas.node()).attr("height")
  centered = null
  x = 0
  y = 0
  if data is not data and centered is data
    x = width/2
    y = height/2
    centered = null
  else
    centerArea = path.centroid(data)
    x = centerArea[0]
    y = centerArea[1]
    centered = data

  canvas.attr("transform", "translate("+width/2+","+height/2+")scale(2)translate(" + -x + "," + -y + ")")

# Fungsi untuk menampilkan hasil dari koneksi Origin District dengan CY/District pada peta Jabodetabek
# Parameters
# - target: element target yang akan di-append
# - data: data hasil koneksi Origin District
# - type: berupa string, untuk membedakan antara data dari Origin District dengan data hasil koneksi
window.appendResult = (target, data, type) ->
  if type == "destination"
    content = "<tr>"
    content += "<td><a href='#' class='result-data' data-code='#{data[0]}'>#{data[0]}</a></td>"
    content += "<td>#{data[1]}</td>"
    content += "<td>#{data[2]}</td>"
    content += "</tr>"
  else if type == "source"
    content = "<h4>Source: #{data}</h4>"

  target.append(content)

# Fungsi untuk mengaktifkan garis penghubung saat klik data hasil koneksi
window.activeConnectorLine = (code) ->
  connctor_line = $("line.connector-line")
  connctor_line.each (i,d) ->
    d3.select(d).style("stroke", "#444").style("opacity", 0.5)
    if d3.select(d).attr("code") is code
      originX2 = d3.select(d).attr("x2")
      originY2 = d3.select(d).attr("y2")
      d3.select(d)
        .style("stroke", "#f00")
        .style("opacity", 1)
        .attr({x2: d3.select(d).attr("x1"), y2: d3.select(d).attr("y1")})
        .transition()
          .duration(800)
          .ease("linear")
          .attr({x2: originX2, y2: originY2})

window.connectAllCyToCy = ->
  console.log "masuk.."
  d3.csv "/map/collector_yards.csv", (result) ->
    for re in result
      if re.type is "CY"
        coordinate = window.jakartaProjection([re.X, re.Y])
        for mo in window.movementOut
          if mo.origin_code is re.code
            dst = window.jakartaProjection([mo.destination_x_original, mo.destination_y_original])
            window.jakartaCanvas.append("rect")
              .attr("x", dst[0])
              .attr("y", dst[1])
              .attr("code", mo.origin_code)
              .attr("type", "CY")
              .attr("width", rectSize)
              .attr("height", rectSize)
              .style("fill", "green")
              .style("opacity", 0.5)
              .attr("class", "cy-movement-out")
            drawConnectorLine([(coordinate[0]+(rectSize/2)), (coordinate[1]+(rectSize/2))], [(dst[0]+(rectSize/2)), (dst[1]+(rectSize/2))], window.jakartaCanvas, mo.origin_code)
      else
        coordinate = window.jakartaProjection([re.X, re.Y])
        for mo in window.movementOut
          if mo.origin_code is re.code
            dst = window.jakartaProjection([mo.destination_x_original, mo.destination_y_original])
            window.jakartaCanvas.append("circle")
              .attr("r", circleRadius)
              .attr("cx", dst[0])
              .attr("cy", dst[1])
              .attr("code", mo.origin_code)
              .attr("type", "LBM")
              .style("fill", "red")
              .style("opacity", 0.5)
              .attr("class", "cy-movement-out")
            drawConnectorLine([x1, y1], dst, window.jakartaCanvas, mo.origin_code)

ready = ->
  # Global variabel
  width = $("#maps").width()
  winHeight = $(window).height() - 50
  jakartaHeight = winHeight * 0.65
  javaHeight = winHeight * 0.35

  d3.csv "/map/movement_in.csv", (result) ->
    window.movementIn = result

  d3.csv "/map/movement_out.csv", (result) ->
    window.movementOut = result

  # d3.csv "/map/collector_yards.csv", (collectorYards) ->
  #   window.collectorYards = collectorYards

  window.jakartaProjection = d3.geo.mercator().rotate([-105.88,5.87,0]).scale(width*30).translate([0, 0])
  window.jakartaPath = d3.geo.path().projection(window.jakartaProjection)

  window.javaProjection = d3.geo.mercator().rotate([-105,5.80,0]).scale(width*5).translate([0, 0])
  window.javaPath = d3.geo.path().projection(window.javaProjection)

  setMapsRatio(winHeight,jakartaHeight,javaHeight)
  loadJabodetabekMap(width,winHeight,jakartaHeight)
  loadJavaMap(width,winHeight,javaHeight)
  # connectAllCyToCy()

  # Untuk percobaan
  $("body").on "click", ".btn-call-origin", (e) ->
    e.preventDefault()
    district = $(this).data "district"
    connectFromOrigin(district, window.movementIn)

  $("body").on "click", ".btn-call-cy", (e) ->
    e.preventDefault()
    code = $(this).data "code"
    connectFromCy(code, window.movementOut)

  # Untuk percobaan
  $("body").on "click", ".result-data", (e) ->
    e.preventDefault()
    code = $(this).data "code"
    activeConnectorLine(code)

$(window).resize ->

$(document).ready ready
$(document).on('page:load', ready);