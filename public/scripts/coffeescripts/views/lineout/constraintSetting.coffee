define [
  "jquery"
  "underscore"
  "backbone"
  "rivets"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/lineout/constraintSetting.html"
], ($, _, Backbone, rivets, ConstraintSettingView) ->
  ConstraintSettingTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      # Using Underscore we can compile our template with data
      data =
        title: "Constraint Setting"
        inputs: [
          {
            label: 'Tare'
            unit: "kg"
            rv: 'tare'
          }    
          {
            label: 'Max. Gross'
            unit: "kg"
            rv: 'max_gross'
          } 
          {
            label: 'Max. Height'
            unit: "mm"
            rv: 'max_height'
          }  
          {
            label: 'Overhang Len'
            unit: "mm"
            rv: 'overhang_len'
          }  
          {
            label: 'Overhang Wid'
            unit: "mm"
            rv: 'overhang_wid'
          }  
          {
            label: 'Max. Pack'
            unit: "#"
            rv: 'max_pack'
          }             
        ]
      compiledTemplate = _.template(ConstraintSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  ConstraintSettingTemplate
