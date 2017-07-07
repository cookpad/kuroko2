$(function(){
  $("#new_job_suspend_schedule").
    on("ajax:success", function(e, data, status, xhr){
      $("#suspend-cron-error").hide();
    }).
    on("ajax:error", function(e, xhr, status, error) {
      $("#suspend-cron-error").show().html("<p>Error: " + xhr.responseJSON.join(' ') + "</p>");
    });
});
