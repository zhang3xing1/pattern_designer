define [
  "jquery"
  "underscore"
  "backbone"
  "jqueryEditable"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/pattern/index.html"
], ($, _, Backbone, JqueryEditable, PatternsIndexView) ->
  PatternsIndexTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Pattern"
        buttons: ['Edit', 'Clone', 'Delete', 'Info']
      compiledTemplate = _.template(PatternsIndexView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate


      # # Rename Function
      # option =
      #   trigger: $("#Rename")
      #   action: "click"

      # $("[id^='layer-item-']").on('click', (el) ->
      #   $("[id^='layer-item-']").removeClass('selected-item')
      #   $(this).addClass('selected-item')
      #   $(".selected-item").editable option, (e) ->
      #     console.log "rename worked!"
      #     return
      #   return
      #   )


      # $("select").editable option, (e) ->
      #   console.log "rename worked!"
      #   return   

      return
  )
  
  # Our module now returns our view
  PatternsIndexTemplate
