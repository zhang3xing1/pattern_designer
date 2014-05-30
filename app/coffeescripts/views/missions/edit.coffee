define [
  "jquery"
  "underscore"
  "backbone"
  'jqueryMultiSelect'

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/edit.html"
], ($, _, Backbone, JqueryMultiSelect, MissionsEditView) ->
  MissionsEditTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Edit Mission"
        cells: ['Name', 'Creator', 'Company', 'Product', 'Code']
        buttons: ['SALVA', 'SACA', 'Save As', 'Reload']
      compiledTemplate = _.template(MissionsEditView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      # $('#my-select').multiSelect()
      return
  )
  
  # Our module now returns our view
  MissionsEditTemplate
