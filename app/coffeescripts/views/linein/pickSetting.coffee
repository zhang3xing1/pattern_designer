define [
  "jquery"
  "underscore"
  "backbone"
  "bootstrapSwitch"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/pickSetting.html"
], ($, _, Backbone, bootstrapSwitch, PickSettingView) ->
  PickSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Box Pick Setting"
        buttons: ['Box Info', 'Box Place Location', 'Box Pick Location', 'Addtional Info']

      compiledTemplate = _.template(PickSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
        
  )
  
  # Our module now returns our view
  PickSettingTemplate
