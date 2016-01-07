ready = ->
  ac = $("#keyword").autocomplete
    minLength: 1
    source: (request, response) ->
      source_type = ""
      selected = $("input[name='source_type']:checked")
      if selected.length > 0
        source_type = selected.val()

      $.ajax
        url: $("#keyword").data("source")
        dataType: 'json'
        data:
          autocomplete:
            keyword: request.term
            source_type: source_type
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
      content = "
        <strong>" + item.id_full + " - " + item.name + "</strong>
        <div style='font-size: 0.7em'>jk. " + item.sex + ", tgl. lahir " + item.dob + "</div>
      "
      $("<li>").append("<a href='#{show_patient_path}/" + item.id + "' data-remote='true'>" + content + "</a>").appendTo ul


$(document).ready ready
$(document).on 'page:update', ready