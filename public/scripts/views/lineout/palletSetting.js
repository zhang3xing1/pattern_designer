(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/lineout/PalletSetting.html"], function($, _, Backbone, rivets, PalletSettingView) {
    var PalletSettingTemplate;
    PalletSettingTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Pallet Setting",
          inputs: [
            {
              label: 'Length',
              rv: 'pallet_length',
              unit: "mm"
            }, {
              label: 'Width',
              rv: 'pallet_width',
              unit: "mm"
            }, {
              label: 'Height',
              rv: 'pallet_height',
              unit: "mm"
            }, {
              label: 'Weight',
              rv: 'pallet_weight',
              unit: "g"
            }, {
              label: 'Sleepsheet Height',
              rv: 'sleepsheet_height',
              unit: "mm"
            }
          ]
        };
        compiledTemplate = _.template(PalletSettingView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return PalletSettingTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=palletSetting.js.map
*/
