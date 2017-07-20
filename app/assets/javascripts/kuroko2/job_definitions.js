// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

jQuery(function ($) {
  $('.star-holder').delegate('.star', 'ajax:complete', function (xhr, status) {
    var currentTarget = xhr.currentTarget;
    var definitionsPath = $('.star').data("definitions-path");

    switch (status.status) {
      case 200: // deleted
        var definitionId = status.responseJSON['job_definition_id'];

        var elem = $('<a class="star" rel="nofollow" data-remote="true" data-method="post"><i class="fa fa-star-o"></i></a>')
          .attr("href", definitionsPath + "/" + definitionId + "/stars")
          .attr("data-definition-id", definitionId);

        $(currentTarget).replaceWith(elem);

        break;
      case 201: // created
        var starId = status.responseJSON['id'];
        var definitionId = status.responseJSON['job_definition_id'];

        var elem = $('<a class="star" rel="nofollow" data-remote="true" data-method="delete"><i class="fa fa-star"></i></a>')
          .attr("href", definitionsPath + "/" + definitionId + "/stars/" + starId)
          .attr("data-star-id", starId)
          .attr("data-definition-id", definitionId);

        $(currentTarget).replaceWith(elem);

        break;
    }
  });

  $('#instances-holder').delegate('#instances', 'ajax:complete', function (xhr, status) {
    switch (status.status) {
      case 200: // pagination
        $('#instances').replaceWith(status.responseText);

        break;
    }
  });

  $('#schedules-holder').delegate('#schedules', 'ajax:complete', function (xhr, status) {
    switch (status.status) {
      case 200:
      case 201:
        var schedulesPath = $('#schedules').data("schedules-path");

        $.get(schedulesPath, function (data) {
          $('#schedules').replaceWith(data);
        });
        break;
      case 400:
        $('#cron-field').addClass("has-error");

        break;
    }
  });

  $('#suspend-schedules-holder').delegate('#suspend-schedules', 'ajax:complete', function (xhr, status) {
    switch (status.status) {
      case 200:
      case 201:
        var schedulesPath = $('#suspend-schedules').data("suspend-schedules-path");

        $.get(schedulesPath, function (data) {
          $('#suspend-schedules').replaceWith(data);
        });
        break;
      case 400:
        $('#suspend-cron-field').addClass("has-error");

        break;
    }
  });

  $('#admin_assignments_user_id').select2();

  $('#adhoc-launch').submit(function(event) {
      event.preventDefault();
      var $form = $(this);

      $.ajax({
          url: $form.attr('action'),
          type: $form.attr('method'),
          data: $form.serialize(),
          timeout: 10000,

          success: function(result, textStatus, xhr) {
              window.location.href = result.url;
          },

          error: function(xhr, textStatus, error) {
              $("#launchAdHocModal-error").show().html("<p>Error: " + xhr.responseJSON.reason + "</p>");
          }
      });
  });
});
