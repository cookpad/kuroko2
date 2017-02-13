// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

jQuery(function ($) {
  var logIntervalId;
  var notifyIfNeeded = function (status, name) {
    if (!('Notification' in window)) {
      return;
    }

    if (Notification.permission === 'granted' && Cookies.get('notification') === 'on') {
      var notification = new Notification(
        "[" + status + "] " + name,
        {"icon": window.location.origin + "/assets/kuroko2/kuroko-logo-" + status.toLowerCase() + ".png"}
      );
      notification.onclick = function () {
        notification.close();
        window.focus();
      };
    }
  };
  var updateInstance = function () {
    var instancePath = $('#instance').data("instance-path");

    $.get(instancePath, function (data) {
      $('#instance').replaceWith(data);
      notifyIfNeeded($('#instance-status').text(), $('#definition-name').text());
    });
  };
  var updateLogs = function () {
    var logsPath = $('#logs').data("logs-path");

    $.get(logsPath, function (data) {
      $('#logs').html($(data).find('#logs').html());

      if (!$('#logs table').data("reload")) {
        clearInterval(logIntervalId);
        updateInstance();
      }
    });
  };

  var updateTokens = function () {
    var tokensPath = $('#tokens').data("tokens-path");

    $.get(tokensPath, function (data) {
      $('#tokens').replaceWith(data);
    });
  };

  var executionLogToken;
  var executionLogIntervalId;
  var appendExecutionLogs = function () {
    var apiPath = $('#execution_logs').data('api-path');
    $.getJSON(apiPath, { "token": executionLogToken }, function(data) {
      data['events'].forEach(function(event) {
        $('#execution_log_body').append(
          $('<tr>').append(
            $('<td>').addClass('nowrap').text(event["timestamp"]),
            $('<td>').text(event.pid),
            $('<td>').text(event.uuid),
            $('<td>').addClass('log').html(event['message'])
          )
        );
      });

      if(executionLogToken != data['token'] ) {
        executionLogToken = data['token'];
      } else {
        clearInterval(executionLogIntervalId);
      }
    }).fail( function(data, status, error) {
      if (!$('#logs table').data("reload")) {
        clearInterval(executionLogIntervalId);
      }
    });
  };

  var startGetExecutionLog = function() {
    executionLogIntervalId = setInterval(appendExecutionLogs, 2000);
  };

  var updateAll = function () {
    updateTokens();
    updateLogs();
  };

  if ($('#logs table').data("reload")) {
    logIntervalId = setInterval(updateAll, 2000);
  }

  if ($('#execution_logs').size() > 0) {
    startGetExecutionLog();
  }
});

jQuery(function ($) {
  $(document).keyup(function (e) {
    // '\' key
    if (e.keyCode == 220) {
      $('#cancel-button').toggle();
      $('#force-cancel-button').toggle();
    }
  });
});
