define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/frame/show.html"
], ($, _, Backbone, FrameShowView) ->
  FrameShowTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Frame"
        coordinates: ['X', 'Y', 'Z', 'R']
      compiledTemplate = _.template(FrameShowView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  FrameShowTemplate
