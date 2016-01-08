ready = ->
  source_type = ""
  species_types = []

  ac = $("#keyword").autocomplete
    minLength: 1
    source: (request, response) ->
      # set source_type
      selected = $("input[name='source_type']:checked")
      if selected.length > 0
        source_type = selected.val()

      # set species array
      $("input[name='species_types[]']:checked").each ->
        species_types.push($(this).val())

      console.log "tes", species_types

      # send request
      $.ajax
        url: $("#keyword").data("source")
        dataType: 'json'
        data:
          autocomplete:
            keyword: request.term
            source_type: source_type
          species_types: species_types
        success: (data) ->
          response data
          return
      return
    focus: (event, ui) ->
      return
    select: (event, ui) ->
      return
    response: (event, ui) ->
      return

  # patient autocomplete menu formater
  unless ac.data("ui-autocomplete") is undefined
    show_patient_path = $("#show_patient_path").val()
    ac.data("ui-autocomplete")._renderItem = (ul, item) ->

      content = "<a href='#'>"
      if item.category is "in"
        content += "<strong>#{ item.source_district_name }</strong>"
      else
        if source_type is "cy_sub_district"
          content += "<strong>#{ item.source_sub_district_name }</strong>"
          content += "<div style='font-size: 0.8em'>kab. #{ item.source_district_name }</div>"
        else
          content += "<strong>#{ item.source_code }</strong>"
          content += "<div style='font-size: 0.8em'>kec. #{ item.source_sub_district_name }</div>"
          content += "<div style='font-size: 0.8em'>kab. #{ item.source_district_name }</div>"
      content += "</a>"

      $("<li>").append(content).appendTo ul


$(document).ready ready
$(document).on 'page:update', ready