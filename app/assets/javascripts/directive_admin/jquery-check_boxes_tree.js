$.extend($.fn, {
  checkBoxesTree: function() {
    $.each(this, function() {
      var tree = $(this),

      applyVisibility = function(parent, el) {
        el || (el = tree.find('[data-parent="' + parent.attr('name') + '"]'));
        var checked = parent.is(':checked');
        if (el.length) {
          el[checked ? 'show' : 'hide']();
          if (!checked) {
            el.find(':input').prop('checked', false);
          }
        }
      },

      updateTree = function() {
        tree.find('[data-parent]').each(function() {
          var el = $(this);
          applyVisibility(tree.find('[name="' + el.attr('data-parent') + '"]'), el);
        });
      };

      updateTree();

      tree.find(':input').change(function(event) {
        applyVisibility($(event.target));
      });

      tree.find('a').click(function(event) {
        event.preventDefault();
        var a = $(event.target);
        a.closest('div').find(':input').prop('checked', a.hasClass('select'));
        updateTree();
      });

    });
  }
});
