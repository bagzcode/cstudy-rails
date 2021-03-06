# Get checked radio buttons by name
window.getSelectedRadioButton = (name) ->
  selected = $("input[name='#{name}']:checked")
  if selected.length > 0
    return selected.val()
  return null

# Get checked checkboxes by name
window.getSelectedCheckBoxes = (name) ->
  result = []
  $("input[name='#{name}']:checked").each ->
    result.push($(this).val())
  return result

ready = ->

  # # Autocomplete on filter
  # ac = $("#keyword").autocomplete
  #   minLength: 1
  #   source: (request, response) ->
  #     $.ajax
  #       url: $("#keyword").data("source")
  #       dataType: 'json'
  #       data:
  #         autocomplete:
  #           keyword: request.term
  #           source_type: getSelectedRadioButton('source_type')
  #           destination_type: getSelectedRadioButton('destination_type')
  #         species_types: getSelectedCheckBoxes('species_types[]')
  #       success: (data) ->
  #         response data
  #         return
  #     return
  #   focus: (event, ui) ->
  #     return
  #   select: (event, ui) ->
  #     source_type = getSelectedRadioButton('source_type')
  #     destination_type = getSelectedRadioButton('destination_type')

  #     console.log source_type, ", ", destination_type

  #     if source_type is "cy_code"
  #       console.log "action", "connectFromCy"
  #       connectFromCy(ui.item.source_code, "/movements/#{ui.item.id}.csv?source_type=#{source_type}&destination_type=#{destination_type}")
  #     else
  #       console.log "action", "connectFromOrigin"
  #       connectFromOrigin(ui.item.source_district_name, "/movements/#{ui.item.id}.csv?source_type=#{source_type}&destination_type=#{destination_type}")
  #     return
  #   response: (event, ui) ->
  #     return

  # # patient autocomplete menu formater
  # unless ac.data("ui-autocomplete") is undefined
  #   show_patient_path = $("#show_patient_path").val()
  #   source_type = getSelectedRadioButton('source_type')

  #   ac.data("ui-autocomplete")._renderItem = (ul, item) ->
  #     content = "<a href='#'>"
  #     if item.category is "in"
  #       content += "<strong>#{ item.source_district_name }</strong>"
  #     else
  #       if source_type is "cy_sub_district"
  #         content += "<strong>#{ item.source_sub_district_name }</strong>"
  #         content += "<div style='font-size: 0.8em'>kab. #{ item.source_district_name }</div>"
  #       else
  #         content += "<strong>#{ item.source_code }</strong>"
  #         content += "<div style='font-size: 0.8em'>kec. #{ item.source_sub_district_name }</div>"
  #         content += "<div style='font-size: 0.8em'>kab. #{ item.source_district_name }</div>"
  #     content += "</a>"

  #     $("<li>").append(content).appendTo ul

  # Handles sending filter on button click
  # It goes to movements#results and should returns script
  #
  $("body").on "click", "#show_results", (e) ->
    e.preventDefault()

    $.ajax
      url: $(this).data("url")
      dataType: 'script'
      data:
        movement_types: getSelectedCheckBoxes('movement_types[]')
        species_types: getSelectedCheckBoxes('species_types[]')
        origin_collector_types: getSelectedCheckBoxes('origin_collector_types[]')
        destination_collector_types: getSelectedCheckBoxes('destination_collector_types[]')
        origin_weekly_volume:
          from: $("#origin_weekly_volume_from").val()
          to: $("#origin_weekly_volume_to").val()
        destination_weekly_volume:
          from: $("#destination_weekly_volume_from").val()
          to: $("#destination_weekly_volume_to").val()
        origin_distance:
          from: $("#origin_distance_from").val()
          to: $("#origin_distance_to").val()
        collector_distance:
          from: $("#collector_distance_from").val()
          to: $("#collector_distance_to").val()
      error: (xhr, ajaxOptions, thrownError) ->
        console.log xhr.status
        console.log thrownError

  # Handles button for check/uncheck all checkboxes in a .form-group
  $("body").on "click", ".toggle-checkboxes", (e) ->
    wrapper = $(this).closest(".form-group")
    if $(this).is(":checked")
      wrapper.find("input:checkbox").prop("checked", true)
    else
      wrapper.find("input:checkbox").prop("checked", false)

  # Unchecked .toggle-checkboxes when one or more of checkboxes are unchecked
  $("body").on "click", "input:checkbox", (e) ->
    wrapper = $(this).closest(".form-group")
    unless wrapper is undefined
      toggle = wrapper.find(".toggle-checkboxes")
      unless toggle is undefined
        unchecked = wrapper.find("input:checkbox").not(".toggle-checkboxes").not(":checked")
        if unchecked.length is 0
          toggle.prop("checked", true)
        else
          toggle.prop("checked", false)




$(document).ready ready
$(document).on('page:load', ready);