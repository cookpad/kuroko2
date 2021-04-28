$ ->
  datasetPath = $('#timeline').data('dataset-path')
  return unless datasetPath

  container = $('#timeline')
  options = {
    zoomable: false,
    orientation: 'both',
    order: (a, b) ->
      return a.end - b.end
  }
  timeline = null

  callback = (response) ->
    if timeline == null
      timeline = new vis.Timeline(
        container.get(0),
        response.data,
        $.extend(options, {start: response.start, end: response.end})
      )
    else
      timeline.setItems(response.data)
      timeline.setOptions({start: response.start, end: response.end})

  $.get(datasetPath, callback)
  setInterval ->
    $.get(datasetPath, callback)
  , 10000
