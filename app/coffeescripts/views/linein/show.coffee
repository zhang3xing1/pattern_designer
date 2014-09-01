define [
  "jquery"
  "underscore"
  "backbone"
  "rivets"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/show.html"
], ($, _, Backbone, rivets, LineinShowView) ->
  LineinShowTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Line In"
        buttons: [
          {
            name: 'Box Info'
            router: "#boxSetting"
          }
          {
            name: 'Box Place Location'
            router: "#placeSetting"
          }
          {
            name: 'TCP Setting'
            router: "#pickSetting"
          }
          {
            name: 'Additional Info'
            router: "#additionalInfo"
          }                              
        ]
      compiledTemplate = _.template(LineinShowView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  LineinShowTemplate
