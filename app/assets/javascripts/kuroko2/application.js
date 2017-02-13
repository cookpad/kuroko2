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
});
