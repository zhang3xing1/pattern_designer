(function() {
  define(["jquery", "underscore", "backbone", "jqueryEditable", "text!templates/pattern/index.html"], function($, _, Backbone, JqueryEditable, PatternsIndexView) {
    var PatternsIndexTemplate;
    PatternsIndexTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Pattern",
          buttons: ['Edit', 'Clone', 'Delete', 'Info']
        };
        compiledTemplate = _.template(PatternsIndexView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return PatternsIndexTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/
