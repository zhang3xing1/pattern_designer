define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/program/current.html"
], ($, _, Backbone, programCurrentTemplate) ->
  ProgramCurrentTemplate = Backbone.View.extend(
    el: $("#test1")
    render: ->
      
      # Using Underscore we can compile our template with data
      data = {title: "Mission Status"}
      compiledTemplate = _.template(programCurrentTemplate, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  ProgramCurrentTemplate
