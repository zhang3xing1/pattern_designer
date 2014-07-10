#every share data of single mission will be store here
define ["logger", "tinybox", 'jquery', 'backbone', 'mission','rivets'], (Logger, Tinybox, $, Backbone, Mission, rivets) ->
  class AppController
    constructor: ->
      @logger = Logger.create 
      @mission = Mission.create
      @new_mission = Mission.create
      @last_action = undefined

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
      @logger.dev "[appController before_action]: #{route}"
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
      @last_action = {route: route, params: params[0]}
      @logger.dev "[appController after_action last_action]: #{@last_action.route}|#{@last_action.params}"
      if route == 'program' || route == ''
        window.appController.aGetRequest('test_var', (data)->
          @logger.dev("in aGetRequest: #{data}")
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
            # alert "Select value: " + values
            # copy select item 
            #$('#my-select').prepend( "<option value='#{a_layer.name}-----#{Math.random()*10e15}'>#{a_layer.name}</option>" )
            
            # get select layer value
            regex = /\s*-----\s*/
            value = option_value[0].split(regex)
            value_name = value[0]

            new_option_value = "#{value_name}-----#{Math.random()*10e16}"
            $('#my-select').prepend( "<option value='#{new_option_value}'>#{value_name}</option>" )
            $('#my-select').multiSelect('refresh')
            @logger.dev "[afterSelect]: old: #{option_value}"
            @logger.dev "[afterSelect]: new: #{new_option_value}"
            return 
          afterDeselect: (option_value) =>
            # remove selected item
            regex = /\s*-----\s*/
            value = option_value[0].split(regex)
            value_name = value[0]

            $("option[value='" + option_value + "']").remove()
            @logger.dev "[afterDeselect]: #{option_value}"
            $('#my-select').multiSelect('refresh')

            return        

    setBoard: (newBoard) ->
      @board = newBoard

    setSelectedLayer: (layer) ->
      @mission.set('selected_layer', layer)
    selectedLayer: ->
      layer = @mission.get('selected_layer')
      if layer == undefined
        return false
      else
        return layer
    getLayers: ->
      @mission.get('available_layers')    
    saveLayer: (action) ->
      # todo validator
      new_layer = @board.saveLayer(action)
      @mission.addLayer(new_layer)

      @logger.dev "[appController] saveLayer -> #{action}"
    # getLayerByName: (layer_name) ->
    #   # todo
    #   @logger.dev '[appController] - getLayerByName'
    #   result = @mission.getLayerByName(layer_name)
    #   console.log result
    #   @logger.dev '[appController] - getLayerByName done!'
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

