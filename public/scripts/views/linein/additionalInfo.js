(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/linein/additionalInfo.html"], function($, _, Backbone, rivets, LineinShowView) {
    var LineinShowTemplate;
    LineinShowTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Additional Info"
        };
        compiledTemplate = _.template(LineinShowView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return LineinShowTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=additionalInfo.js.map
*/
