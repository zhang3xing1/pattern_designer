(function() {
  define(["jquery", "underscore", "backbone", "tinybox", "text!templates/missions/show.html"], function($, _, Backbone, Tinybox, MissionsShowView) {
    var MissionsShowTemplate;
    MissionsShowTemplate = Backbone.View.extend({
      initialize: function(options) {
        return options.app.debugInfo;
      },
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Current Mission",
          cells: ['Name', 'Creator', 'Company', 'Product', 'Code'],
          buttons: [
            {
              name: 'Save',
              router: "save"
            }, {
              name: 'Save Copy',
              router: "save_copy"
            }, {
              name: 'Save As',
              router: "save_as"
            }, {
              name: 'Reload',
              router: "reload"
            }
          ]
        };
        compiledTemplate = _.template(MissionsShowView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return MissionsShowTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=show.js.map
*/
