jQuery(function ($) {
  function setDeifinitionLink(script) {
    script = script.replace(/sub_process:\s+(\d+)\s*\n/, function(match, jobId) {
      return '<a href="/definitions/' + jobId + '">' + match + '</a>';
    });

    script = script.replace(/^wait:\s*(.+)\s*$/gm, function(match, option) {
      return 'wait: ' + option.replace(/(\d+)\/\w+/g, function(match, jobId){
	return '<a href="/definitions/' + jobId + '">' + match + '</a>';
      });
    });

    return script
  }

  $('pre.kuroko-script').each(function(){
    var script = $(this).html();
    $(this).html(setDeifinitionLink(script));
  });
});
