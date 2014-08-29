(function() {
  define(["jquery", "underscore", "backbone", 'jqueryMultiSelect', "text!templates/missions/edit.html"], function($, _, Backbone, JqueryMultiSelect, MissionsEditView) {
    var MissionsEditTemplate;
    MissionsEditTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Edit Mission"
        };
        compiledTemplate = _.template(MissionsEditView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return MissionsEditTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=edit.js.map
*/
