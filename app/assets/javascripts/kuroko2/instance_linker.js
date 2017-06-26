jQuery(function ($) {
  var logParent = document.querySelector('#logs tbody');
  var observer = new MutationObserver(function(mutations) {
    if (mutations.some(x =>
      x.addedNodes
        && x.addedNodes instanceof NodeList
        && x.addedNodes.length > 0
        && x.type == 'childList'
      )
    ) {
      $('td.log').each(function() {
        var logText = $(this).html();
        $(this).html(
          logText.replace(/instance#(\d+)\/(\d+)(?:\s+|\.|$)/, function(match, jobId, instanceId) {
            return '<a href="/definitions/' + jobId + '/instances/' + instanceId+ '">' + match + '</a>';
          })
        );
      });
    }
  });
  observer.observe(logParent, {childList: true, substree: true});
});
