(function() {
  define(["jquery", "underscore", "backbone", "bootstrapSwitch", "text!templates/linein/pickSetting.html"], function($, _, Backbone, bootstrapSwitch, ToolSettingView) {
    var ToolSettingTemplate;
    ToolSettingTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Tool Setting"
        };
        compiledTemplate = _.template(ToolSettingView, data);
        return this.$el.append(compiledTemplate);
      }
    });
    return ToolSettingTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=toolSetting.js.map
*/
