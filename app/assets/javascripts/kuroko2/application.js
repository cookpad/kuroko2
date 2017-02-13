//= require jquery
//= require jquery_ujs
//= require ./bootstrap
//= require ./js.cookie.js
//= stub kuroko2/instance_linker
//= require_tree
//= require moment
//= require bootstrap-sortable
//= require select2
//= require vis

jQuery(function ($) {

  $("[data-toggle='offcanvas']").click(function (e) {
    e.preventDefault();

    //If window is small enough, enable sidebar push menu
    if ($(window).width() <= 992) {
      $('.row-offcanvas').toggleClass('active');
      $('.left-side').removeClass("collapse-left");
      $(".right-side").removeClass("strech");
      $('.row-offcanvas').toggleClass("relative");
    } else {
      //Else, enable content streching
      $('.left-side').toggleClass("collapse-left");
      $(".right-side").toggleClass("strech");
    }
  });

  var showNotificationStatus = function () {
    if (Notification.permission === 'granted') {
      if (Cookies.get('notification') === 'on') {
        $('#notification').html("<i class=\"fa fa-volume-up\"></i> on");
      } else {
        $('#notification').html("<i class=\"fa fa-volume-off\"></i> off");
      }
    } else if (Notification.permission === 'denied') {
      $('#notification').html("<i class=\"fa fa-volume-off\"></i> off");
    }
  }

  $('#notification').click(function (e) {
    if (Notification.permission === 'default') {
      Notification.requestPermission(function (permission) {
        if (permission === "granted") {
          Cookies.set('notification', 'on');
        }
        showNotificationStatus();
      });
    } else if (Notification.permission === 'granted') {
      if (Cookies.get('notification') === 'on') {
        Cookies.set('notification', 'off');
      } else {
        Cookies.set('notification', 'on');
      }
      showNotificationStatus();
    }
  });

  showNotificationStatus();
});
