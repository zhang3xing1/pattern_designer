(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/linein/boxSetting.html"], function($, _, Backbone, rivets, BoxSettingView) {
    var BoxSettingTemplate;
    BoxSettingTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Box Setting"
        };
        compiledTemplate = _.template(BoxSettingView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return BoxSettingTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=boxSetting.js.map
*/
