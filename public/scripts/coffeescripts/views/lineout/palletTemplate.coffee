define [
  "jquery"
  "underscore"
  "backbone"
  "jqueryEditable"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/lineout/palletTemplate.html"
], ($, _, Backbone, JqueryEditable, PalletTemplateView) ->
  PalletTemplateTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      data =
        title: "Pallet Dim"


      compiledTemplate = _.template(PalletTemplateView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate

      return
  )
  
  # Our module now returns our view
  PalletTemplateTemplate
