(function() {
  define(["jquery", "underscore", "backbone", "text!templates/lineout/show.html"], function($, _, Backbone, LineoutShowView) {
    var LineoutShowTemplate;
    LineoutShowTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Line Out",
          buttons: [
            {
              name: 'Pallet Setting',
              router: "#palletSetting"
            }, {
              name: 'Constraints',
              router: "#constraintSetting"
            }, {
              name: 'Layout',
              router: "#layout"
            }
          ]
        };
        compiledTemplate = _.template(LineoutShowView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return LineoutShowTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=show.js.map
*/
