(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/linein/placeSetting.html"], function($, _, Backbone, rivets, PlaceSettingView) {
    var PlaceSettingTemplate;
    PlaceSettingTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Box Place Setting"
        };
        compiledTemplate = _.template(PlaceSettingView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return PlaceSettingTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=placeSetting.js.map
*/
