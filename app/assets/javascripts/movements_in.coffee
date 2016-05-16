# #Functions for conncection from origin district to CY on Jabodetabek

# # Fungsi untuk memanggil Origin District di peta Jawa
# # Mungkin fungsi ini akan di-panggil saat klik pilihan di autocomplete
# # Parameters:
# # - district_name: string, untuk memanggil path district yang sesuai dengan district_name yang dikirim
# # - connections: array (of movements object)
# window.connectFromOrigin = (district_name, connections) ->
#   # Untuk menghilangkan circle dari district di peta jabodetabek
#   d3.selectAll(".center-dot-district").remove()

#   # Untuk mengkosongkan html elemen #line_canvas
#   d3.select("#line_canvas").html("")
#   d3.selectAll("line.connector-line").remove()
#   d3.selectAll(".cy-movement-out").remove()

#   # Untuk mengkosongkan html elemen result data
#   $("#result_body table tbody").html("")

#   # Mendeklarasikan variabel lineCanvas
#   lineCanvas = d3.select("#line_canvas").append("svg")
#     .attr("height", $(window).height() - 50)
#     .attr("width", $("#maps").width())

#   # Select semua path District pada peta Jawa
#   d3.selectAll(".java-area").each (d) ->
#     d3.select(this).style("fill", "#e9e5dc")

#     # Membuat titik tengah dari District pada peta Jawa
#     dot = window.javaCanvas.append("circle")
#       .attr("class", "center-dot-district")
#       .attr("cx", window.javaPath.centroid(d)[0])
#       .attr("cy", window.javaPath.centroid(d)[1])
#       .attr("r", 0)
#       .style("fill", "#428bca")

#     # Mencocokkan antara properties path District dengan district_name yang dikirim
#     if d.properties.KAB_KOTA is district_name
#       centralizeSelectedArea(window.javaCanvas, window.javaPath, d)
#       d3.select(this).style("fill", "#428bca")
#       # d3.csv connections, (result) ->
#       if $("#destination_type_collector_yards").is(":checked")
#         fromOriginToCy(d.properties.KAB_KOTA, dot, lineCanvas, connections)
#       else if $("#destination_type_cy_sub_districts").is(":checked")
#         fromOriginToCySubDistrict(d.properties.KAB_KOTA, dot, lineCanvas, connections)
#       else if $("#destination_type_cy_districts").is(":checked")
#         fromOriginToCyDistrict(d.properties.KAB_KOTA, dot, lineCanvas, connections)

# # DARI ORIGIN DISTRICT KE CY/DISTRICT CY/SUB DISTRICT CY
# # Fungsi untuk menkoneksikan antara Origin District dengan CY di peta Jabodetabek
# # Jika fungsi ini akan di panggil dari respond js controller,
# # tambahkan parameter data hasil filter ke dalam fungsi ini
# # Saat ini untuk menampilkan CY yang terkait dengan origin menggunakan data
# # window.movementIn yang di-filter dengan "if"
# # Parameters:
# # - originDistrict
# # - dot
# # - canvas
# # - data
# window.fromOriginToCy = (originDistrict, dot, canvas, data) ->
#   # Untuk menghilangkan circle dari district di peta Jabodetabek
#   d3.selectAll(".dot-district-jabodetabek").remove()

#   # Untuk hidden semau CY di peta jabodetabek
#   d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

#   for mi in data
#     if mi.destination_district is originDistrict
#       coordinate = window.jakartaProjection([mi.destination_x, mi.destination_y])
#       window.jakartaCanvas.append("rect")
#         .attr("x", coordinate[0])
#         .attr("y", coordinate[1])
#         .attr("code", mi.destination_code)
#         .attr("type", "CY")
#         .attr("width", rectSize)
#         .attr("height", rectSize)
#         .style("fill", "green")
#         .style("opacity", 0.5)
#         .attr("class", "collector-yards")
      
#       origin = [(dot.node().getBoundingClientRect().x-12), dot.node().getBoundingClientRect().y]
#       destination = [coordinate[0]+(rectSize/2), coordinate[1]+(rectSize/2)]
#       drawConnectorLine(origin, destination, canvas, mi.destination_code)
#       # write_data = [mi.destination_code, mi.destination_district, mi.weekly_volume]
#       # appendResult($("#result_body table tbody"), write_data, "destination")

# # Fungsi untuk menkoneksikan antara Origin District dengan Sub District yang ada di peta Jabodetabek
# window.fromOriginToCySubDistrict = () ->
#   # Untuk menghilangkan circle dari district di peta jabodetabek
#   d3.selectAll(".dot-district-jabodetabek").remove()

#   # Untuk hidden semau CY di peta jabodetabek
#   d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

#   alert("Sub District Coordinate is Not Available")

# # Fungsi untuk menkoneksikan antara Origin District dengan CY di peta Jabodetabek
# # Jika fungsi ini akan di panggil dari respond js controller,
# # tambahkan parameter data hasil filter ke dalam fungsi ini
# # Saat ini untuk menampilkan District yang terkait dengan Origin District menggunakan data
# # window.movementIn yang di-filter dengan "if"
# # Parameters:
# # - originDistrict
# # - dot
# # - canvas
# # - data
# window.fromOriginToCyDistrict = (originDistrict, dot, canvas, data) ->
#   # Untuk hidden semau CY di peta jabodetabek
#   d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")
#   district = d3.selectAll(".jabodetabek-area")

#   for mi in data
#     if originDistrict is mi.origin_district
#       district.each (d) ->
#         if d.properties.KAB_KOTA is mi.destination_district
#           # Panggil fungsi untuk menampilkan circle CY District di peta Jabodetabek
#           jbdtbPoint = jabodetabekPointDistrict(d)

#           # Mendeklarasikan variabel yang akan dikirim ke fungsi untuk menarik garis antara Origin District dengan District Jabodetabek
#           # getBoundingClientRect() untuk mendapatkan koordinat elemen terhadap halaman di mozilla
#           origin = [(dot.node().getBoundingClientRect().x-12), dot.node().getBoundingClientRect().y]
#           destination = [(jbdtbPoint.node().getBoundingClientRect().x-11), (jbdtbPoint.node().getBoundingClientRect().y+4)]

#           # Panggil fungsi membuat garis
#           drawConnectorLine(origin, destination, canvas, mi.destination_code)