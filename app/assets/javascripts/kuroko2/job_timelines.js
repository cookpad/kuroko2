$(function() {
  const datasetPath = $('#timeline').data('dataset-path');
  if (!datasetPath) {
    return;
  }

  const container = $('#timeline');
  const options = {
    zoomable: false,
    orientation: 'both',
    order(a, b) {
      return a.end - b.end;
    }
  };
  let timeline = null;

  const callback = function(response) {
    if (timeline === null) {
      return timeline = new vis.Timeline(
        container.get(0),
        response.data,
        $.extend(options, {start: response.start, end: response.end})
      );
    } else {
      timeline.setItems(response.data);
      return timeline.setOptions({start: response.start, end: response.end});
    }
  };

  $.get(datasetPath, callback);
  return setInterval(() => $.get(datasetPath, callback), 10000);
});
