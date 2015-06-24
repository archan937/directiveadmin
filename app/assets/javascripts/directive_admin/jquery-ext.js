$.extend({
  express: function(expression) {
    return expression.split(".").reduce(function(object, property) {
      return object[property];
    }, window);
  }
});
