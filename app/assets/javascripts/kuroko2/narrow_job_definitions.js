jQuery(function ($) {
  var link_to_table_row = function(){
    $('tr[data-href]').css("cursor", "pointer").click(function(e){
      document.location = $(this).data('href');
    });
  };
  link_to_table_row();

  var bind_data = function(data) {
    $('#tags').html($(data).find('#tags').html());
    $('#definitions').html($(data).find('#definitions').html());
    $('#pagination').html($(data).find('#pagination').html());
    $('html,body').scrollTop(0);
    link_to_table_row();
    $.bootstrapSortable();
  };

  $('#tags').on({ 'ajax:success': function(e, data, status, xhr) {
      bind_data(data);
      history.pushState('', '', $(this).attr('href'));
    }
  }, '.js-narrow-tag');

  $('#job_search').on({ 'ajax:success': function(e, data, status, xhr) {
    bind_data(data)
    url = '?' + $(this).serialize()
    history.pushState('', '', url);
  } }, 'form');

  $('#pagination').on({ 'ajax:success': function(e, data, status, xhr) {
    bind_data(data)
    history.pushState('', '', $(this).attr('href'));
  } }, 'a');

  $(window).on('popstate', function(e){
    $.get(location.href).then(function(data) { bind_data(data) });
  });
});
