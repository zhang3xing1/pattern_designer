(function() {
  define(["jquery", "underscore", "backbone", "jqueryEditable", "text!templates/lineout/palletTemplate.html"], function($, _, Backbone, JqueryEditable, PalletTemplateView) {
    var PalletTemplateTemplate;
    PalletTemplateTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Pallet Dim"
        };
        compiledTemplate = _.template(PalletTemplateView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return PalletTemplateTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=palletTemplate.js.map
*/
