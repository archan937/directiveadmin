DirectiveAdmin = (function() {
  var baseUrl = window.location.pathname,
      newUrl = baseUrl + '/new',
      editRegExp = new RegExp(RegExp.escape(baseUrl) + '\/\\d+\/edit'),

  init = function() {
    var metaTag = $('meta[name="inline-editable"]');
    if (metaTag.length && metaTag.attr('content') == 'yes') {
      if (!$('div.index_as_table tbody').children().length) {
        renderCreateRecord();
      }
      hijackLinks();
    }
    metaTag.remove();
  },

  renderCreateRecord = function() {
    $('div.index_as_table tbody').append('<tr class="create_one"><td colspan="99">There are no ' + $('ul#tabs li.current').text() + ' yet. <a href="' + newUrl + '">Create one</a></td></tr>');
  },

  hijackLinks = function() {
    $(document).on('click', 'div.index_as_table tbody a', function(event) {
      var target = $(event.target), href = target.attr('href'), tr = target.closest('tr');
      if (target.hasClass('save')) {
        save();
      } else if (target.hasClass('cancel')) {
        cancel(tr);
      } else if (href == newUrl) {
        newRecord();
      } else if (href.match(editRegExp)) {
        editRecord(tr);
      } else {
        return;
      }
      event.preventDefault();
    });
  },

  save = function() {

  },

  cancel = function(row) {
    $.ajax({
      url: baseUrl + '/' + 1,
      beforeSend: function(xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
      },
      complete: function(data, status, xhr) {
        row.replaceWith(data.responseText);
      }
    });
  },

  newRecord = function() {
    $('div.index_as_table tbody .create_one').hide();
    $('div.index_as_table tbody').append('<tr><td>New!</td></tr>');
  },

  editRecord = function(row) {
    $.ajax({
      url: baseUrl + '/' + 1 + '/edit',
      beforeSend: function(xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
      },
      complete: function(data, status, xhr) {
        var el = $(data.responseText.replace(/type="(number|date)"/g, 'type="text"'));
        row.replaceWith(el);
        el.find('.date_picker input').datepicker({
          dateFormat: 'yy-mm-dd'
        });
      }
    });
  };

  return {
    init: init
  }
}());

$(DirectiveAdmin.init);
