define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/placeSetting.html"
], ($, _, Backbone, PlaceSettingView) ->
  PlaceSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Box Place Setting"
        buttons: ['Box Info', 'Box Place Location', 'Box Place Location', 'Addtional Info']


      compiledTemplate = _.template(PlaceSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  PlaceSettingTemplate
