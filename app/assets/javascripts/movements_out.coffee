# # Parameters:
# # - cy_code: string
# # - connections: array (of movements object)
# window.connectFromCy = (cy_code, connections) ->
#   selectedCy = null;
#   $("#result_body table tbody").html("")
#   d3.selectAll("line.connector-line").remove()
#   d3.select("#line_canvas").html("")
#   d3.selectAll(".dot-district-jabodetabek").remove()
#   d3.selectAll(".collector-yards").each (d) ->
#     if d3.select(this).attr("code") is cy_code
#       d3.select(this).attr("selected", true)
#       d3.select(this).attr("title", cy_code)
#       selectedCy = d3.select(this)
#     else
#       d3.select(this).attr("selected", null)
#       d3.select(this).attr("title", null)
#   window.selectedCode = cy_code
#   # console.log "data_url: ", data_url

#   # d3.csv connections, (result) ->
#   if $("#destination_type_collector_yards").is(":checked")
#     fromCyToCy(selectedCy, connections)
#   else if $("#destination_type_cy_sub_districts").is(":checked")
#     fromCyToCySubDistrict(selectedCy, connections)
#   else if $("#destination_type_cy_districts").is(":checked")
#     fromCyToCyDistrict(selectedCy, connections)

# # DARI CY KE CY/LBM/CY SUB DISTRICT/CY DISTRICT
# # Fungsi untuk menkoneksikan antara CY dengan CY/LBM di peta Jabodetabek
# # Parameters:
# # - param (string): selected source code or CY/LBM code
# # - connections (array): Array of Movement object
# window.fromCyToCy = (selected_cy, data) ->
#   d3.selectAll(".collector-yards").attr("class", "hidden collector-yards")
#   d3.selectAll(".cy-movement-out").remove()
#   selected_cy.attr("class", "collector-yards")

#   filled = (data) ->
#     if data.type_destination is "CY"
#       "green"
#     else if data.type_destination is "LBM"
#       "red"
#     else if data.type_destination is "AS"
#       "blue"
#     else
#       "yellow"

#   titelize = (data) ->
#     label = []
#     if data.destination_lbm_cy_id isnt ""
#         label.push(data.destination_lbm_cy_id)
#     if data.destination_sub_district isnt ""
#         label.push(data.destination_sub_district)
#     if data.destination_district isnt ""
#         label.push(data.destination_district)
    
#     if label.length is 0
#       return "N/A"
#     else
#       return label.join(", ")



#   for mo in data
#     if mo.origin_code is selected_cy.attr("code")
#       coordinate = window.jakartaProjection([mo.destination_x_original, mo.destination_y_original])
#       window.jakartaCanvas.append("rect")
#         .attr("x", coordinate[0])
#         .attr("y", coordinate[1])
#         .attr("code", mo.origin_code)
#         .attr("type", mo.type_destination)
#         .attr("title", titelize(mo))
#         .attr("width", rectSize)
#         .attr("height", rectSize)
#         .style("fill", filled(mo))
#         .style("opacity", 0.5)
#         .attr("class", "cy-movement-out")
      
#       destination = [coordinate[0]+(rectSize/2), coordinate[1]+(rectSize/2)]
#       if selected_cy.attr("type") is "CY"
#         origin = [parseInt(selected_cy.attr("x"))+(rectSize/2), parseInt(selected_cy.attr("y"))+(rectSize/2)]
#       else
#         origin = [parseInt(selected_cy.attr("cx")), parseInt(selected_cy.attr("cy"))]

#       drawConnectorLine(origin, destination, window.jakartaCanvas, selected_cy.code)

# # Fungsi untuk menkoneksikan antara CY dengan CY Sub District di peta Jabodetabek
# window.fromCyToCySubDistrict = (param) ->
#   # Untuk menghilangkan circle dari district di peta jabodetabek
#   d3.selectAll(".dot-district-jabodetabek").remove()

#   # Untuk hidden semau CY di peta jabodetabek
#   d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

#   # Menampilkan selected CY, setelah semua CY di tambahkan class: hidden
#   param.attr("class", "collector-yards")

#   alert("Sub District Coordinate is Not Available")

# # Fungsi untuk menkoneksikan antara CY dengan CY District di peta Jabodetabek
# # Parameters:
# # - param (string): selected source code or CY/LBM code
# # - connections (array): Array of Movement object
# window.fromCyToCyDistrict = (param, connections) ->
#   # Untuk hidden semau CY di peta jabodetabek
#   d3.selectAll(".collector-yards").attr("class", "collector-yards hidden")

#   # Menampilkan selected CY, setelah semua CY di tambahkan class: hidden
#   param.attr("class", "collector-yards")

#   d3.selectAll(".jabodetabek-area").each (d) ->
#     for c in connections
#       if c.destination_district is d.properties.KAB_KOTA
#         jbdtbPoint = jabodetabekPointDistrict(d)
#         x1 = parseInt(param.node().getBBox().x)+(rectSize/2)
#         y1 = parseInt(param.node().getBBox().y)+(rectSize/2)
#         x2 = jbdtbPoint.node().getBBox().x+4
#         y2 = jbdtbPoint.node().getBBox().y+4
#         drawConnectorLine([x1, y1],[x2, y2], window.jakartaCanvas, c.origin_code)