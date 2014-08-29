(function() {
  define(["jquery", "underscore", "backbone", "rivets", "text!templates/linein/show.html"], function($, _, Backbone, rivets, LineinShowView) {
    var LineinShowTemplate;
    LineinShowTemplate = Backbone.View.extend({
      el: $("#right_board"),
      render: function() {
        var compiledTemplate, data;
        data = {
          title: "Line In",
          buttons: [
            {
              name: 'Box Info',
              router: "#boxSetting"
            }, {
              name: 'Box Place Location',
              router: "#placeSetting"
            }, {
              name: 'Box Pick Location',
              router: "#pickSetting"
            }, {
              name: 'Additional Info',
              router: "#additionalInfo"
            }
          ]
        };
        compiledTemplate = _.template(LineinShowView, data);
        this.$el.append(compiledTemplate);
      }
    });
    return LineinShowTemplate;
  });

}).call(this);

/*
//@ sourceMappingURL=show.js.map
*/
