jQuery(function ($) {
  $('td.log').each(function(){
    var logText = $(this).html();
    $(this).html(
      logText.replace(/instance#(\d+)\/(\d+)(?:\s+|\.)/, function(match, jobId, instanceId){
	return '<a href="/definitions/' + jobId + '/instances/' + instanceId+ '">' + match + '</a>';
      })
    );
  });
});
