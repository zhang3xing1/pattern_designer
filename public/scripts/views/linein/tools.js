(function() {
  define(["jquery", "underscore", "backbone", "jqueryEditable", "text!templates/linein/tools.html"], function($, _, Backbone, JqueryEditable, ToolsView) {
    var ToolsTemplate;
    ToolsTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Select Tool"
        };
        compiledTemplate = _.template(ToolsView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return ToolsTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=tools.js.map
*/
