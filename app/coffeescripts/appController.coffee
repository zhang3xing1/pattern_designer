#every share data of single mission will be store here
define ["logger", "tinybox", 'jquery', 'backbone', 'mission','rivets'], (Logger, Tinybox, $, Backbone, Mission, rivets) ->
  class AppController
    constructor: ->
      @logger = Logger.create 
      @mission = Mission.create


    aGetRequest: (varName, callback, programName) ->
      programName = "gui_example_test_2"  unless programName?
      $.ajax
        url: "get?var=" + varName + "&prog=" + programName
        cache: false
        success: (data) ->
          callback data
          return
      return

    aSetRequest: (varName, newVarValue, callback, programName) ->
      programName = "gui_example_test_2"  unless programName?
      if newVarValue is ""
        alert varName + "new value is Empty!"
        return
      $.ajax
        url: "set?var=" + varName + "&prog=" + programName + "&value=" + newVarValue
        cache: false
        success: (data) ->
          callback data, varName
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

    after_action: (route, params) ->
      @logger.dev "[appController after_action]: #{route}"
      if route == 'program'
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
                       
      if route == 'patterns'
        console.log @mission.get('available_layers')
        _.each(@mission.get('available_layers'),((a_layer) ->
            $('#patterns').append( "<li class=\"list-group-item\" id=\"layer-item-1\">#{a_layer.name}</li>" )
          ),this)

        $("[id^='layer-item-']").on('click', (el) ->
          $("[id^='layer-item-']").removeClass('selected-item')
          $(this).addClass('selected-item')
          return
        )

      if route == 'mission'
        _.each(@mission.get('available_layers'),((a_layer) ->
            $('#my-select').prepend( "<option value='#{a_layer.name}-----#{Math.random()*10e16}'>#{a_layer.name}</option>" )
          ),this)        
        $('#my-select').multiSelect
          afterSelect: (values) ->
            # alert "Select value: " + values
            # copy select item 
            #$('#my-select').prepend( "<option value='#{a_layer.name}-----#{Math.random()*10e15}'>#{a_layer.name}</option>" )
            console.log values
            $('#my-select').prepend( "<option value='-----#{Math.random()*10e16}'>EXAMPLE</option>" )
            $('#my-select').multiSelect()
            return

          afterDeselect: (values) ->
            console.log values
            # remove selected item
            # alert "Deselect value: " + values
            return        
    setBoard: (newBoard) ->
      @board = newBoard

    saveBoard: ->
      # todo validator
      new_layer = @board.saveLayer()
      @mission.addLayer(new_layer)

      @logger.dev "[appController] - saveBoard"

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

