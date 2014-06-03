define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/lineout/constraintSetting.html"
], ($, _, Backbone, ConstraintSettingView) ->
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
          }    
          {
            label: 'Max. Gross'
            unit: "kg"
          } 
          {
            label: 'Max. Height'
            unit: "mm"
          }  
          {
            label: 'Overhang Len'
            unit: "mm"
          }  
          {
            label: 'Overhang Wid'
            unit: "mm"
          }  
          {
            label: 'Max. Pack'
            unit: "#"
          }             
        ]
      compiledTemplate = _.template(ConstraintSettingView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  ConstraintSettingTemplate
