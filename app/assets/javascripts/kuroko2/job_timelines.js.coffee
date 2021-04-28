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

  callback = (response) ->
    container.empty()
    new vis.Timeline(
      container.get(0),
      response.data,
      $.extend(options, {start: response.start, end: response.end})
    )

  $.get(datasetPath, callback)
  setInterval ->
    $.get(datasetPath, callback)
  , 10000
