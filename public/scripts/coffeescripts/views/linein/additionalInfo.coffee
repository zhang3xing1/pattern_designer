define [
  "jquery"
  "underscore"
  "backbone"
  "rivets"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/additionalInfo.html"
], ($, _, Backbone, rivets, LineinShowView) ->
  LineinShowTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Additional Info"
      compiledTemplate = _.template(LineinShowView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  LineinShowTemplate
