(function() {
  define(["jquery", "underscore", "backbone", "bootstrapSwitch", "text!templates/linein/calculateTool.html"], function($, _, Backbone, bootstrapSwitch, CalculateView) {
    var CalculateTemplate;
    CalculateTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Calculate Tool"
        };
        compiledTemplate = _.template(CalculateView, data);
        return this.$el.append(compiledTemplate);
      }
    });
    return CalculateTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=calculateTool.js.map
*/
