define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/pattern/index.html" 
], ($, _, Backbone, PatternIndexView) ->
  PatternIndexViewTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data = {title: "Pattern Designer"}
      compiledTemplate = _.template(PatternIndexView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  PatternIndexViewTemplate
