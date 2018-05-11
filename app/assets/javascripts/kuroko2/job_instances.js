// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

jQuery(function ($) {
  var logIntervalId;
  var notifyIfNeeded = function (status, name, image) {
    if (!('Notification' in window)) {
      return;
    }

    if (Notification.permission === 'granted' && Cookies.get('notification') === 'on') {
      var notification = new Notification("[" + status + "] " + name, {"icon": image[status.toLowerCase()]});
      notification.onclick = function () {
        notification.close();
        window.focus();
      };
    }
  };
  var updateInstance = function () {
    var instancePath = $('#instance').data("instance-path");
    var currentStatus = $('#instance').data("current-status");
    $.get(instancePath, function (data) {
      $('#instance').replaceWith(data);
      if (currentStatus != 'success' && currentStatus != 'canceled') {
        notifyIfNeeded($('#instance-status').text(), $('#definition-name').text(), $('#notification').data());
      }
    });
  };

  var updateLogs = function () {
    var logsPath = $('#logs').data("logs-path");

    $.get(logsPath, function (data) {
      var tbody = $('#logs tbody');
      var lastLogId = +tbody.data('last-log-id');
      if (data.logs && data.logs.length !== 0) {
        data.logs.forEach(function(log) {
          if (log.id > lastLogId) {
            var tr = $('<tr>');
            var label = $('<span class="label">').text(log.level).addClass(log.class_for_label);
            tr.append($('<td>').append(label));
            tr.append($('<td class="nowrap">').text(log.created_at));
            tr.append($('<td class="log">').html(log.message_html));
            tbody.append(tr);
          }
        });

        tbody.data('last-log-id', data.logs[data.logs.length - 1].id);
      }

      $('#logs').data("reload", data.reload);
      if (!data.reload) {
        clearInterval(logIntervalId);
        updateInstance();
      }
      tbody.find('.loading').empty();
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
      if (!$('#logs').data("reload")) {
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

  if ($('#logs tbody').size() > 0) {
    logIntervalId = setInterval(updateAll, 2000);
    updateAll();
  }

  if ($('#execution_logs').size() > 0) {
    startGetExecutionLog();
  }

  $('#force-cancel-button').click(function(evt) {
    if (confirm("Force-cancel is STRONGLY DISCOURAGED because it breaks invariants of Kuroko2's internal state.\nAre you sure to cancel this job instance forcibly?") && confirm('Are you really sure?') && confirm('Do you understand EXACTLY what happens?')) {
      // run default
    } else {
      evt.preventDefault();
      evt.stopPropagation();
    }
  });
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
