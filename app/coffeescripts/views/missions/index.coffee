define [
  "jquery"
  "underscore"
  "backbone"
  "jqueryEditable"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/index.html"
], ($, _, Backbone, JqueryEditable, MissionsIndexView) ->
  MissionsIndexTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Load Mission"
        # cells: ['Name', 'Creator', 'Company', 'Product', 'Code']
        buttons: ['Update', 'Rename', 'Load', 'Delete', 'Info']
        buttons: [
          {
            name: 'Update'
            router: "update"
          }
          {
            name: 'Rename'
            router: "rename"
          }
          {
            name: 'Load'
            router: "load"
          }
          {
            name: 'Delete'
            router: "delete"
          }  
          {
            name: 'Info'
            router: "info"
          }                  
        ]
      compiledTemplate = _.template(MissionsIndexView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate


      # Rename Function
      option =
        trigger: $("#Rename")
        action: "click"

      $("[id^='mission-item-']").on('click', (el) ->
        $("[id^='mission-item-']").removeClass('selected-item')
        $(this).addClass('selected-item')
        # $(".selected-item").editable option, (e) ->
        #   console.log "rename worked!"
        #   return
        return
        )


      # $("select").editable option, (e) ->
      #   console.log "rename worked!"
      #   return   

      return
  )
  
  # Our module now returns our view
  MissionsIndexTemplate
