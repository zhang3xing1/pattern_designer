#every share data of single mission will be store here
define ["logger", "tinybox", 'jquery', 'backbone', 'mission'], (Logger, Tinybox, $, Backbone, Mission) ->
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

    after_action: (route, params) ->
      @logger.dev "[appController after_action]: #{route}"
      if route == 'program'
        $($('.form-control')[0]).val(@mission.get('info').name)
        $($('.form-control')[1]).val(@mission.get('info').creator)
        $($('.form-control')[2]).val(@mission.get('info').company)
        $($('.form-control')[3]).val(@mission.get('info').product)
        $($('.form-control')[4]).val(@mission.get('info').code)
        
    ## 
    #
    # Pattern show page
    #
    ##

    setBoard: (newBoard) ->
      @board = newBoard

    saveBoard: ->
      # todo validator
      new_layer = @board.saveLayer()
      @mission.addLayer(new_layer)

      console.log @mission.get('available_layers')
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

