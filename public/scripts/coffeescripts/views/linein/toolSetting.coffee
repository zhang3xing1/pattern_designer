define [
  "jquery"
  "underscore"
  "backbone"
  "bootstrapSwitch"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/pickSetting.html"
], ($, _, Backbone, bootstrapSwitch, ToolSettingView) ->
  ToolSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Tool Setting"

      compiledTemplate = _.template(ToolSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
        
  )
  
  # Our module now returns our view
  ToolSettingTemplate
