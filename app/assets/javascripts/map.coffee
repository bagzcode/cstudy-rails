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
  window.jakartaCanvas.selectAll("circle.collector-yards")
    .data(window.collectorYards)
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
    .data(window.collectorYards)
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

# DARI CY KE CY/LBM/CY SUB DISTRICT/CY DISTRICT
# Fungsi untuk menkoneksikan antara CY dengan CY/LBM di peta Jabodetabek
# Parameters:
# - param (string): selected source code or CY/LBM code
# - connections (array): Array of Movement object
window.connectToCy = (param, connections) ->
  console.log "connections: ", connections

  destinationCy = [];

  isSelected = (d) ->
    if connections.length is 0
      return true
    for c in connections
      console.log("isSelected", d.code is c.destination_LBM_CY_id)
      if d.code is c.destination_LBM_CY_id
        return true
    return false

  d3.selectAll(".collector-yards").each (d) ->
    if isSelected({code: d3.select(this).attr("code")})
      d3.select(this).attr("class", "collector-yards")
      destinationCy.push(d3.select(this))
    else
      d3.select(this).attr("class", "collector-yards hidden")

  # Menampilkan selected CY, setelah semua CY di tambahkan class: hidden
  param.attr("class", "collector-yards")

  for dcy in destinationCy
    x1 = (param.node().getBBox().x)+(rectSize/2)
    y1 = (param.node().getBBox().y)+(rectSize/2)
    if dcy.attr("type") is "CY"
      x2 = parseInt(dcy.attr("x"))+(rectSize/2)
      y2 = parseInt(dcy.attr("y"))+(rectSize/2)
    else if dcy.attr("type") is "LBM"
      x2 = dcy.attr("cx")
      y2 = dcy.attr("cy")
    drawConnectorLine([x1, y1],[x2, y2], window.jakartaCanvas, dcy.attr("code"))

# Fungsi untuk menkoneksikan antara CY dengan CY Sub District di peta Jabodetabek
window.connectToCySubDistrict = (param) ->
  # Untuk menghilangkan circle dari district di peta jabodetabek
  d3.selectAll(".dot-district-jabodetabek").remove()

  # Untuk hidden semau CY di peta jabodetabek
  d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

  # Menampilkan selected CY, setelah semua CY di tambahkan class: hidden
  param.attr("class", "collector-yards")

  alert("Sub District Coordinate is Not Available")

# Fungsi untuk menkoneksikan antara CY dengan CY District di peta Jabodetabek
# Parameters:
# - param (string): selected source code or CY/LBM code
# - connections (array): Array of Movement object
window.connectToCyDistrict = (param, connections) ->
  # Untuk hidden semau CY di peta jabodetabek
  d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

  # Menampilkan selected CY, setelah semua CY di tambahkan class: hidden
  param.attr("class", "collector-yards")

  d3.selectAll(".jabodetabek-area").each (d) ->
    for c in connections
      if c.destination_district is d.properties.KAB_KOTA
        jbdtbPoint = jabodetabekPointDistrict(d)
        x1 = parseInt(param.node().getBBox().x)+(rectSize/2)
        y1 = parseInt(param.node().getBBox().y)+(rectSize/2)
        x2 = jbdtbPoint.node().getBBox().x+4
        y2 = jbdtbPoint.node().getBBox().y+4
        drawConnectorLine([x1, y1],[x2, y2], window.jakartaCanvas, c.origin_code)

# DARI ORIGIN DISTRICT KE CY/DISTRICT CY/SUB DISTRICT CY
# Fungsi untuk menkoneksikan antara Origin District dengan CY di peta Jabodetabek
# Jika fungsi ini akan di panggil dari respond js controller,
# tambahkan parameter data hasil filter ke dalam fungsi ini
# Saat ini untuk menampilkan CY yang terkait dengan origin menggunakan data
# window.movementIn yang di-filter dengan "if"
# Parameters:
# - originDistrict
# - dot
# - canvas
# - connections
window.connectToJabodetabekCy = (originDistrict, dot, canvas, connections) ->
  # Untuk menghilangkan circle dari district di peta Jabodetabek
  d3.selectAll(".dot-district-jabodetabek").remove()

  # Untuk hidden semau CY di peta jabodetabek
  d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

  for mi in connections
    if mi.origin_district is originDistrict # note neccessary because 'connections' already containes filtered values
      collectorYardsCode = d3.selectAll(".collector-yards")
      collectorYardsCode.each (d) ->
        if d.code is mi.destination_code
          d3.select(this).attr("class", "collector-yards")
          origin = [(dot.node().getBoundingClientRect().x-12), dot.node().getBoundingClientRect().y]
          destination = [(parseInt(d3.select(this).attr("x"))+(rectSize/2)), (parseInt(d3.select(this).attr("y"))+(rectSize/2))]
          drawConnectorLine(origin, destination, canvas, mi.destination_code)
          write_data = [mi.destination_code, mi.destination_district, mi.weekly_volume]
          appendResult($("#result_body table tbody"), write_data, "destination")

# Fungsi untuk menkoneksikan antara Origin District dengan Sub District yang ada di peta Jabodetabek
window.connectToJabodetabekSubDistrict = () ->
  # Untuk menghilangkan circle dari district di peta jabodetabek
  d3.selectAll(".dot-district-jabodetabek").remove()

  # Untuk hidden semau CY di peta jabodetabek
  d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

  alert("Sub District Coordinate is Not Available")

# Fungsi untuk menkoneksikan antara Origin District dengan CY di peta Jabodetabek
# Jika fungsi ini akan di panggil dari respond js controller,
# tambahkan parameter data hasil filter ke dalam fungsi ini
# Saat ini untuk menampilkan District yang terkait dengan Origin District menggunakan data
# window.movementIn yang di-filter dengan "if"
# Parameters:
# - originDistrict
# - dot
# - canvas
# - connections
window.connectToJabodetabekDistrict = (originDistrict, dot, canvas, connections) ->
  # Untuk hidden semau CY di peta jabodetabek
  d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")
  district = d3.selectAll(".jabodetabek-area")

  for mi in connections
    if originDistrict is mi.origin_district
      district.each (d) ->
        if d.properties.KAB_KOTA is mi.destination_district
          # Panggil fungsi untuk menampilkan circle CY District di peta Jabodetabek
          jbdtbPoint = jabodetabekPointDistrict(d)

          # Mendeklarasikan variabel yang akan dikirim ke fungsi untuk menarik garis antara Origin District dengan District Jabodetabek
          # getBoundingClientRect() untuk mendapatkan koordinat elemen terhadap halaman
          origin = [(dot.node().getBoundingClientRect().x-12), dot.node().getBoundingClientRect().y]
          destination = [(jbdtbPoint.node().getBoundingClientRect().x-11), (jbdtbPoint.node().getBoundingClientRect().y+4)]

          # Panggil fungsi membuat garis
          drawConnectorLine(origin, destination, canvas, mi.destination_code)

# Fungsi untuk membuat line atau garis
# Parameter x: berupa array, ex. x = [foo, foo1]
# Parameter y: berupa array, ex. y = [foo, foo1]
# Parameter canvas: canvas tempat line akan di-append
# Parameter data: berupa string, untuk memberikan kode destinasi pada masing2 garis
window.drawConnectorLine = (x,y,canvas,data) ->
  line = canvas.append("line")
    .attr("class", "connector-line")
    .attr("code", data)
    .attr("x1", x[0])
    .attr("x2", x[0])
    .attr("y1", x[1])
    .attr("y2", x[1])
    .style("stroke", "#444")
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
# Parameter target: element target yang akan di-append
# Parameter data: data hasil koneksi Origin District
# Parameter type: berupa string, untuk membedakan antara data dari Origin District dengan data hasil koneksi
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

# Fungsi untuk memanggil Origin District di peta Jawa
# Mungkin fungsi ini akan di-panggil saat klik pilihan di autocomplete
# Parameters:
# - district_name: string, untuk memanggil path district yang sesuai dengan district_name yang dikirim
# - connections: array (of movements object)
window.connectFromOrigin = (district_name, connections) ->
  # Untuk menghilangkan circle dari district di peta jabodetabek
  d3.selectAll(".center-dot-district").remove()

  # Untuk mengkosongkan html elemen #line_canvas
  d3.select("#line_canvas").html("")
  d3.selectAll("line.connector-line").remove()

  # Untuk mengkosongkan html elemen result data
  $("#result_body table tbody").html("")

  # Mendiklarasikan variabel lineCanvas
  lineCanvas = d3.select("#line_canvas").append("svg")
    .attr("height", $(window).height() - 50)
    .attr("width", $("#maps").width())

  # Select semua path District pada peta Jawa
  d3.selectAll(".java-area").each (d) ->
    d3.select(this).style("fill", "#e9e5dc")

    # Membuat titik tengah dari District pada peta Jawa
    dot = window.javaCanvas.append("circle")
      .attr("class", "center-dot-district")
      .attr("cx", window.javaPath.centroid(d)[0])
      .attr("cy", window.javaPath.centroid(d)[1])
      .attr("r", 0)
      .style("fill", "#428bca")

    # Mencocokkan antara properties path District dengan district_name yang dikirim
    if d.properties.KAB_KOTA is district_name
      centralizeSelectedArea(window.javaCanvas, window.javaPath, d)
      d3.select(this).style("fill", "#428bca")
      if $("#destination_type_collector_yards").is(":checked")
        connectToJabodetabekCy(d.properties.KAB_KOTA, dot, lineCanvas, connections)
      else if $("#destination_type_cy_sub_districts").is(":checked")
        connectToJabodetabekSubDistrict(d.properties.KAB_KOTA, dot, lineCanvas, connections)
      else if $("#destination_type_cy_districts").is(":checked")
        connectToJabodetabekDistrict(d.properties.KAB_KOTA, dot, lineCanvas, connections)

# Parameters:
# - cy_code: string
# - connections: array (of movements object)
window.connectFromCy = (cy_code, connections) ->
  selectedCy = null;
  $("#result_body table tbody").html("")
  d3.selectAll("line.connector-line").remove()
  d3.select("#line_canvas").html("")
  d3.selectAll(".dot-district-jabodetabek").remove()
  d3.selectAll(".collector-yards").each (d) ->
    if d3.select(this).attr("code") is cy_code
      d3.select(this).attr("selected", true)
      selectedCy = d3.select(this)
    else
      d3.select(this).attr("selected", null)
  window.selectedCode = cy_code
  console.log "data_url: ", data_url

  if $("#destination_type_collector_yards").is(":checked")
    connectToCy(selectedCy, connections)
  else if $("#destination_type_cy_sub_districts").is(":checked")
    connectToCySubDistrict(selectedCy, connections)
  else if $("#destination_type_cy_districts").is(":checked")
    connectToCyDistrict(selectedCy, connections)

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

  d3.csv "/map/collector_yards.csv", (collectorYards) ->
    window.collectorYards = collectorYards

  window.jakartaProjection = d3.geo.mercator().rotate([-105.88,5.87,0]).scale(width*30).translate([0, 0])
  window.jakartaPath = d3.geo.path().projection(window.jakartaProjection)

  window.javaProjection = d3.geo.mercator().rotate([-105,5.80,0]).scale(width*5).translate([0, 0])
  window.javaPath = d3.geo.path().projection(window.javaProjection)

  setMapsRatio(winHeight,jakartaHeight,javaHeight)
  loadJabodetabekMap(width,winHeight,jakartaHeight)
  loadJavaMap(width,winHeight,javaHeight)

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