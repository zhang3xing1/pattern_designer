#every share data of single mission will be store here
define ["logger", "tinybox", 'jquery', 'backbone', 'mission','rivets'], (Logger, Tinybox, $, Backbone, Mission, rivets) ->
  class AppController
    constructor: ->
      @logger = Logger.create 
      @mission = Mission.create
      @new_mission = Mission.create
      @previous_action = undefined
      @current_action = undefined

      ## view shared
      # pattern index -> for edit layer
      @selected_layer = undefined

      ## mission edit page -> for order of layers
      @removed_layer_index = -1

    aGetRequest: (varName, callback, programName) ->
      programName = @mission.get('program_name') unless programName?
      $.ajax
        url: "get?var=" + varName + "&prog=" + programName
        cache: false
        success: (data) ->
          callback data
          return
      return

    aSetRequest: (varName, newVarValue, callback, programName) ->
      programName = @mission.get('program_name') unless programName?
      if newVarValue is ""
        alert varName + "new value is Empty!"
        return
      $.ajax
        url: "set?var=" + varName + "&prog=" + programName + "&value=" + newVarValue
        cache: false
        success: (data) ->
          callback data, varName
          return    
      return

    # decide if router be valid
    before_action: (route, params) ->
      @previous_action = @current_action
      @current_action = {route: route, params: params[0]}
      @logger.dev "[before_action]: @previous_action #{@previous_action.route} #{@previous_action.params}" if @previous_action != undefined
      @logger.dev "[before_action]: @current_action #{@current_action.route} #{@current_action.params}" if @previous_action != undefined
      rivets.adapters[":"] =
        subscribe: (obj, keypath, callback) ->
          # console.log("1.subscribe:\t #{obj} ||\t #{keypath}")
          obj.on "change:" + keypath, callback
          return

        unsubscribe: (obj, keypath, callback) ->
          # console.log("2.unsubscribe:\t #{obj} ||\t #{keypath}")
          obj.off "change:" + keypath, callback
          return

        read: (obj, keypath) ->
          # console.log("3.read:\t\t\t #{obj} ||\t #{keypath}")
          # if((obj.get keypath) == undefined)
          #   console.log("3.read:++ #{obj[keypath]()} \t #{(obj.get keypath)}")
          #   obj[keypath]()
          # else
          #   obj.get keypath
          obj.get keypath

        publish: (obj, keypath, value) ->
          # console.log("4.publish:\t\t #{obj} ||\t #{keypath}")
          obj.set keypath, value
          return      
      if route == 'saveNewMission'
        # to do: test unsaved mission exist
        @mission = @new_mission
        # window.router.navigate("loadMission", {trigger: true});
    after_action: (route, params) ->
      # @previous_action = {route: route, params: params[0]}
      # @logger.debug "[appController after_action previous_action]: #{@previous_action.route}|#{@previous_action.params}"
      if route == 'program' || route == ''
        window.appController.aGetRequest('test_var', (data)->
          @logger.debug("in aGetRequest: #{data}")
          return
          )

        rivets.bind $('.mission_'),{mission: @mission}
        # window.mission = @mission 
        # window.rivets = rivets 
        # console.log $('.mission_')
        # window.rivets.bind $('.mission_'),{mission: @mission}
      if route == 'boxSetting'
        rivets.bind $('.mission_'),{mission: @mission}

      if route == 'placeSetting'
        rivets.bind $('.mission_'),{mission: @mission}   

      if route == 'additionalInfo' 
        rivets.bind $('.mission_'),{mission: @mission} 

      if route == 'palletSetting'
        rivets.bind $('.mission_'),{mission: @mission}   

      if route == 'constraintSetting'
        rivets.bind $('.mission_'),{mission: @mission}   

      if route == 'createMission'
        rivets.bind $('.mission_'),{mission: @new_mission}   

      if route == 'patterns'
        _.each(@mission.get('available_layers'),((a_layer) ->
            $('#patterns').append( "<li class=\"list-group-item\" id=\"#{a_layer.id}\">#{a_layer.name}</li>" )
          ),this)

        $("[id^='layer-item-']").on('click', (el) ->
          $("[id^='layer-item-']").removeClass('selected-item')
          $(this).addClass('selected-item')
          return
        )

      if route == 'mission'
        window.appController.aSetRequest "test_var", "new code", (data, varName) ->
          console.log("in aSetRequest: new code")
          return

        _.each(@mission.get('available_layers'),((a_layer) ->
            $('#my-select').prepend( "<option value='#{a_layer.name}-----#{Math.random()*10e16}'>#{a_layer.name}</option>" )
          ),this)        
        $('#my-select').multiSelect
          afterSelect: (option_value) =>
            @logger.dev "afterSelect: #{option_value}"

            # get select layer value
            regex = /\s*-----\s*/
            value = option_value[0].split(regex)
            value_name = value[0]

            new_option_value = "#{value_name}-----#{Math.random()*10e16}"
            $('#my-select').prepend( "<option value='#{new_option_value}'>#{value_name}</option>" )
            $('#my-select').multiSelect('refresh')


            # add this select layer to used_layers
            window.appController.addToUsedLayers(value_name, option_value[0])
            console.log window.appController.getUsedLayersOrder()

            ## to keep orgin order, left
            selectable_layers = $(".ms-selectable li:visible span")
            available_layers = window.appController.getAvailableLayersOrder()
            
            order_index = 0
            while order_index < available_layers.length
              to_ordered_layer = available_layers[order_index]
              selectable_layers.each (index) ->
                if $(this).html() == to_ordered_layer
                  $(this).parent().insertBefore($(selectable_layers[order_index]).parent())
                  return false
              # reset selectable_layers
              selectable_layers = $(".ms-selectable li:visible span")
              order_index++


            ## to keep orgin order, right
            ## add name attr for identity
            # remove old identity
            $(".ms-selection li:visible span").removeAttr('layer_id')
            # add identity
            used_layers = window.appController.getUsedLayersOrder()
            selection_layers = $(".ms-selection li:visible span")
            order_index = 0            
            while order_index < used_layers.length 
              to_ordered_layer = used_layers[order_index]
              selection_layers.each (index) ->
                if $(this).html() == to_ordered_layer.name and $(this).attr('layer_id') == undefined
                  console.log "#{$(this).html()}, #{$(this).attr('layer_id')},#{$(this).parent().index()}"
                  console.log "order_index: #{order_index}; to_ordered_layer.id: #{to_ordered_layer.id} "
                  # $(this).parent().insertBefore($(selection_layers[order_index]).parent())
                  $(this).attr('layer_id', to_ordered_layer.id)
                  return false
              selection_layers = $(".ms-selection li:visible span")
              order_index++

            ## rearrange
            # to keep selected order, right

            order_index = 0
            while order_index < used_layers.length 
              to_ordered_layer = used_layers[order_index]
              selection_layers.each (index) ->
                if $(this).attr('layer_id') == to_ordered_layer.id
                  $(this).parent().insertBefore($(selection_layers[order_index]).parent())
                  return false
              selection_layers = $(".ms-selection li:visible span")
              order_index++

            @logger.debug "[afterSelect]: old: #{option_value}"
            @logger.debug "[afterSelect]: new: #{new_option_value}"

            return 
          afterDeselect: (option_value) =>
            @logger.dev "afterDeselect: #{option_value}"
            # remove selected item
            regex = /\s*-----\s*/
            value = option_value[0].split(regex)
            value_name = value[0]

            $("option[value='" + option_value + "']").remove()
            @logger.debug "[afterDeselect]: #{option_value}"
            $('#my-select').multiSelect('refresh')


            ## to keep orgin order
            selectable_layers = $(".ms-selectable li:visible span")
            available_layers = window.appController.getAvailableLayersOrder()
            
            order_index = 0
            while order_index < available_layers.length
              to_ordered_layer = available_layers[order_index]
              selectable_layers.each (index) ->
                if $(this).html() == to_ordered_layer
                  $(this).parent().insertBefore($(selectable_layers[order_index]).parent())
                  return false
              selectable_layers = $(".ms-selectable li:visible span")
              order_index++

            ## to keep orgin order, right
            ## add name attr for identity
            # remove old identity
            $(".ms-selection li:visible span").removeAttr('layer_id')
            # add identity
            window.appController.removeFromUsedLayers(option_value)
            used_layers = window.appController.getUsedLayersOrder()



            selection_layers = $(".ms-selection li:visible span")
            order_index = 0            
            while order_index < used_layers.length 
              to_ordered_layer = used_layers[order_index]
              selection_layers.each (index) ->
                if $(this).html() == to_ordered_layer.name and $(this).attr('layer_id') == undefined
                  # console.log "#{$(this).html()}, #{$(this).attr('layer_id')},#{$(this).parent().index()}"
                  # console.log "order_index: #{order_index}; to_ordered_layer.id: #{to_ordered_layer.id} "
                  # $(this).parent().insertBefore($(selection_layers[order_index]).parent())
                  $(this).attr('layer_id', to_ordered_layer.id)
                  return false
              selection_layers = $(".ms-selection li:visible span")
              order_index++

            ## rearrange
            # to keep selected order, right

            order_index = 0
            while order_index < used_layers.length 
              to_ordered_layer = used_layers[order_index]
              selection_layers.each (index) ->
                if $(this).attr('layer_id') == to_ordered_layer.id
                  $(this).parent().insertBefore($(selection_layers[order_index]).parent())
                  return false
              selection_layers = $(".ms-selection li:visible span")
              order_index++


            return        

    setBoard: (newBoard) ->
      @board = newBoard

    getLayers: ->
      @mission.get('available_layers') 

    saveLayer: (layer_id) ->
      # todo validator
      new_layer = @board.saveLayer(layer_id)
      @mission.addLayer(new_layer)

    getAvailableLayersOrder: ->
      @mission.getAvailableLayersOrder()

    addToUsedLayers: (layer_name, layer_option_value)->
      @mission.addToUsedLayers(layer_name, layer_option_value)

    getUsedLayersOrder: ->
      @mission.getUsedLayersOrder()

    removeFromUsedLayers: (layer_option_value) ->
      @mission.removeFromUsedLayers(layer_option_value)

    # getLayerByName: (layer_name) ->
    #   # todo
    #   @logger.debug '[appController] - getLayerByName'
    #   result = @mission.getLayerByName(layer_name)
    #   console.log result
    #   @logger.debug '[appController] - getLayerByName done!'
    #   result
    default_pattern_params: ->
      canvasStage =  
            width:      280
            height:     360 
            stage_zoom: 1.5

      # color: RGB
      color = 
          stage:   
              red:    255
              green:  255
              blue:   255
          pallet: 
              red:    251
              green:  209
              blue:   175
          overhang: 
              stroke:
                red:    238
                green:  49
                blue:   109
                alpha:  0.5
          boxPlaced:
            inner:
              red:    79
              green:  130
              blue:   246
              alpha:  0.8
              stroke:
                red:    147
                green:  218
                blue:   87
                alpha:  0.5
            outer:
              red:    0
              green:  0
              blue:   0
              alpha:  0
              stroke:
                red:    0
                green:  0
                blue:   0
                alpha:  0
          boxSelected:
            collision:
              inner:
                red:    255
                green:  0
                blue:   0
                alpha:  1
                stroke:
                  red:    147
                  green:  218
                  blue:   87
                  alpha:  0.5
              outer:
                red:    255
                green:  0
                blue:   0
                alpha:  0.5
                stroke:
                  red:    255
                  green:  0
                  blue:   0
                  alpha:  0.5           
            uncollision:
              inner:
                red:    108
                green:  153
                blue:   57
                alpha:  1
                stroke:
                  red:    72
                  green:  82
                  blue:   38
                  alpha:  0.5
              outer:
                red:    0
                green:  0
                blue:   0
                alpha:  0
                stroke:
                  red:    70
                  green:  186
                  blue:   3
                  alpha:  0.5


      pallet =  
            width:    200
            height:   250 
            overhang: 10

      box  =      
            x:      0 
            y:      0
            width:  60  
            height: 20  
            minDistance: 10


      params = 
          pallet: pallet
          box: box
          stage: canvasStage
          color: color  

      params


    # # integer
    # $("button.get." + "integer").click ->
    #   aGetRequest "gui_" + "integer", (data) ->
    #     $("label.get." + "integer").html data
    #     $("#flash").html "Get " + varName + " done!"
    #     return

    #   return

    # $("button.set." + "integer").click ->
    #   setValue = $("input.set.integer").val()
    #   aSetRequest "gui_" + "integer", setValue, (data, varName) ->
    #     $("#flash").html "Set " + varName + " done!"
    #     return

    #   return

  create: new AppController

