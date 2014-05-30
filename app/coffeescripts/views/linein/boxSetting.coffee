define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/boxSetting.html"
], ($, _, Backbone, BoxSettingView) ->
  BoxSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Box Setting"
        buttons: ['Box Info', 'Box Place Location', 'Box Pick Location', 'Addtional Info']


      compiledTemplate = _.template(BoxSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  BoxSettingTemplate
