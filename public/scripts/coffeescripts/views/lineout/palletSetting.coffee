define [
  "jquery"
  "underscore"
  "backbone"
  "rivets"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/lineout/PalletSetting.html"
], ($, _, Backbone, rivets, PalletSettingView) ->
  PalletSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Pallet Setting"

        inputs: [
          {
            label: 'Length'
            rv:  'pallet_length'
            unit: "mm"
          }    
          {
            label: 'Width'
            rv: 'pallet_width'
            unit: "mm"
          } 
          {
            label: 'Height'
            rv: 'pallet_height'
            unit: "mm"
          }  
          {
            label: 'Weight'
            rv: 'pallet_weight'
            unit: "g"
          }   
          {
            label: 'Sleepsheet Height'
            rv: 'sleepsheet_height'
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
