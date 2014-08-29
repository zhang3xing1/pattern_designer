(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/lineout/constraintSetting.html"], function($, _, Backbone, rivets, ConstraintSettingView) {
    var ConstraintSettingTemplate;
    ConstraintSettingTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Constraint Setting",
          inputs: [
            {
              label: 'Tare',
              unit: "kg",
              rv: 'tare'
            }, {
              label: 'Max. Gross',
              unit: "kg",
              rv: 'max_gross'
            }, {
              label: 'Max. Height',
              unit: "mm",
              rv: 'max_height'
            }, {
              label: 'Overhang Len',
              unit: "mm",
              rv: 'overhang_len'
            }, {
              label: 'Overhang Wid',
              unit: "mm",
              rv: 'overhang_wid'
            }, {
              label: 'Max. Pack',
              unit: "#",
              rv: 'max_pack'
            }
          ]
        };
        compiledTemplate = _.template(ConstraintSettingView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return ConstraintSettingTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=constraintSetting.js.map
*/
