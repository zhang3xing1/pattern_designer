define [
  "jquery"
  "underscore"
  "backbone"
  "rivets"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/boxSetting.html"
], ($, _, Backbone, rivets, BoxSettingView) ->
  BoxSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Box Setting"

      compiledTemplate = _.template(BoxSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  BoxSettingTemplate
