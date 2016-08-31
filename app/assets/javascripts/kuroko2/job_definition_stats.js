// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

jQuery(function ($) {
  var groups = new vis.DataSet();
  groups.add({
    id: 'execution-time',
    content: 'ExecutionTime',
  });
  groups.add({
    id: 'memory',
    content: 'Memory',
  });

  var basicOptions = {
    zoomable: false,
    drawPoints: { enabled: true }
  };

  var pointerApproaching = function( $element, distance, event ) {
    var left = $element.offset().left - distance,
        top = $element.offset().top - distance,
        right = left + $element.width() + ( 2 * distance ),
        bottom = top + $element.height() + ( 2 * distance ),
        x = event.pageX,
        y = event.pageY;
    return ( x > left && x < right && y > top && y < bottom );
  };

  var bindTooltipAction = function($target){
    $target.mousemove( function( event ) {
      $('.vis-line-graph svg rect').each(function(){
	if( pointerApproaching($(this), 15, event) ) {
	  $(this).next().show();
        } else {
	  $(this).next().hide();
	}
      });
    });
  };

  var executionTimePath = $('#execution-time').data('execution-time-path')
  if( executionTimePath ) {
    $.get(executionTimePath, function (response) {
      new vis.Graph2d(
        $('#execution-time').get(0),
        response.data,
        groups,
        $.extend(basicOptions, { dataAxis: { left: { title: { text: 'Minutes' } } }, interpolation: false, start: response.start_at, end: response.end_at })
      );

      bindTooltipAction($('#execution-time'));
    });
  }

  var memoryPath = $('#memory').data('memory-path')
  if( memoryPath ) {
    $.get(memoryPath, function (response) {
      new vis.Graph2d(
        $('#memory').get(0),
        response.data,
        groups,
        $.extend(basicOptions, { dataAxis: { left: { title: { text: 'Kbytes' } } } })
      );
    });
  }
});
