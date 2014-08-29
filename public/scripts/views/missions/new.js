(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/missions/new.html"], function($, _, Backbone, rivets, MissionsNewView) {
    var MissionsNewTemplate;
    MissionsNewTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Create Mission",
          cells: ['Name', 'Creator', 'Company', 'Product', 'Code'],
          buttons: ['Update', 'Rename', 'Load', 'Delete', 'Info']
        };
        compiledTemplate = _.template(MissionsNewView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return MissionsNewTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=new.js.map
*/
