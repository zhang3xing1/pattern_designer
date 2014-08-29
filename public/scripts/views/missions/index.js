(function() {
  define(["jquery", "underscore", "backbone", "jqueryEditable", "text!templates/missions/index.html"], function($, _, Backbone, JqueryEditable, MissionsIndexView) {
    var MissionsIndexTemplate;
    MissionsIndexTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data, option;
        data = {
          title: "Load Mission",
          buttons: ['Update', 'Rename', 'Load', 'Delete', 'Info'],
          buttons: [
            {
              name: 'Rename',
              router: "rename"
            }, {
              name: 'Load',
              router: "load"
            }, {
              name: 'Delete',
              router: "delete"
            }, {
              name: 'Info',
              router: "info"
            }
          ]
        };
        compiledTemplate = _.template(MissionsIndexView, data);
        this.$el.append(compiledTemplate);
        option = {
          trigger: $("#Rename"),
          action: "click"
        };
        $("[id^='mission-item-']").on('click', function(el) {
          $("[id^='mission-item-']").removeClass('selected-item');
          $(this).addClass('selected-item');
        });
      }
    });
    return MissionsIndexTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/
