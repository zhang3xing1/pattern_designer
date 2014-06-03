define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/lineout/PalletSetting.html"
], ($, _, Backbone, PalletSettingView) ->
  PalletSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Pallet Setting"
        inputs: [
          {
            label: 'Length'
            unit: "mm"
          }    
          {
            label: 'Width'
            unit: "mm"
          } 
          {
            label: 'Height'
            unit: "mm"
          }  
          {
            label: 'Weight'
            unit: "g"
          }   
          {
            label: 'Sleepsheet Height'
            unit: "mm"
          }             
        ]
      compiledTemplate = _.template(PalletSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  PalletSettingTemplate
