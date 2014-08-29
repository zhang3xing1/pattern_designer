(function() {
  define(["jquery", "underscore", "backbone", "text!templates/frame/show.html"], function($, _, Backbone, FrameShowView) {
    var FrameShowTemplate;
    FrameShowTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Frame",
          coordinates: ['X', 'Y', 'Z', 'R']
        };
        compiledTemplate = _.template(FrameShowView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return FrameShowTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=show.js.map
*/
