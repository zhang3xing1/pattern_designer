(function() {
  define(["jquery", "underscore", "backbone", "bootstrapSwitch", "rivets", "text!templates/linein/pickSetting.html"], function($, _, Backbone, bootstrapSwitch, rivets, PickSettingView) {
    var PickSettingTemplate;
    PickSettingTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "TCP Setting"
        };
        compiledTemplate = _.template(PickSettingView, data);
        return this.$el.append(compiledTemplate);
      }
    });
    return PickSettingTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=pickSetting.js.map
*/
