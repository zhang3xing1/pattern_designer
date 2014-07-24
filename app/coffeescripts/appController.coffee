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

      # @remote_url = 'http://172.22.117.38/'
      @program_name = 'pd_db'

      @mission_saved_flag = true
      @pattern_saved_flag = true
    # http://192.168.56.2/set?var=gui_string&prog=gui_example_test_2&value=%27ddddd%27
    getVarRequest: (varName, callback) ->
      get_url = "get?var=" + varName + "&prog=" + programName
      $.ajax
        url: get_url
        cache: false
        dataType: 'JSONP'
        success: (data) ->
          callback data
          return
        done: () ->
          window.appController.logger.dev "[get]: #{get_url}"
        error: () ->
          window.appController.logger.dev "[get]: error"
      return

    setVarRequest: (varName, newVarValue, callback) ->
      set_url = "set?var=" + varName + "&prog=" + programName + "&value=" + newVarValue
      $.ajax
        url: set_url
        cache: false
        dataType: 'JSONP'
        success: (data) ->
          callback data, varName
          return 
        done: () ->
          window.appController.logger.dev "[set]: #{set_url}"
        error: () ->
          window.appController.logger.dev "[set]: error"
      return

    flash: (options={closable: true})->
      $('#popup').html(options.message)
      $("#popup").modal
        escapeClose: options.closable
        clickClose: options.closable
        showClose: options.closable

    # decide if router be valid
    before_action: (route, params) ->
      action = params[0]
      @previous_action = @current_action
      @current_action = {route: route, action: params[0]}
      @logger.debug "[before_action]: @previous_action #{@previous_action.route} #{@previous_action.action}" if @previous_action != undefined
      @logger.debug "[before_action]: @current_action #{@current_action.route} #{@current_action.action}" if @previous_action != undefined
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
      if route == 'mission/*action'
        if action == 'new'
          if window.appController.mission_saved_flag == true
            @mission = @new_mission
          else
            @flash({message: 'Do you want to abandon the modification?'})
            window.router.navigate("#program", {trigger: true})
            return false
      
      rivets.formatters.currency =
        read: (value) ->
          console.log 'rivets read'
          console.log value
          (value / 100).toFixed 2

        publish: (value) ->
          console.log 'rivets publish'
          console.log value
          Math.round parseFloat(value) * 100

      # rivets.formatters.integer_ =
      #   read: (value) ->
      #     console.log "rivets read #{value}"
      #     value

      #   publish: (value) ->
          re = /^\+?[1-9][0-9]*$/
          isInt = re.test(value)
      #     console.log "rivets publish #{value} #{isInt}"
      #     1 

    after_action: (route, params) ->
      action = params[0]
      rivets.bind $('.mission_'),{mission: @mission}
      # if route == 'program' || route == ''
      #   window.appController.aGetRequest('index', (data)->
      #     alert data
      #     @logger.debug("in aGetRequest: #{data}")
      #     return
      #     )

      if route == 'pickSetting'
        rivets.bind $('.mission_'),{mission: @new_mission}   

      if route == 'placeSetting'
        orient_value = window.appController.mission.get('orient')
        $("[name='orient']").bootstrapSwitch('state', orient_value) 
        $("[name='orient']").on "switchChange.bootstrapSwitch", (event, state) ->
          # console.log this # DOM element
          # console.log event # jQuery event
          # console.log state # true | false

          # state turn to be off, then button 'set' turn to be button 'PLACE'
          window.appController.mission.set('orient', state)
      
      if route == 'additionalInfo'
        length_wise_value = window.appController.mission.get('length_wise')
        $("[name='length']").bootstrapSwitch('state', length_wise_value) 
        $("[name='length']").on "switchChange.bootstrapSwitch", (event, state) ->
          window.appController.mission.set('length', state)
          $("[name='cross']").bootstrapSwitch('state', !state) 

        
        cross_wise_value = window.appController.mission.get('cross_wise')
        $("[name='cross']").bootstrapSwitch('state', cross_wise_value) 
        $("[name='cross']").on "switchChange.bootstrapSwitch", (event, state) ->
          window.appController.mission.set('length', state)
          $("[name='length']").bootstrapSwitch('state', !state) 
      
      if route == 'patterns'
        _.each(@mission.get('available_layers'),((a_layer) ->
            $('#patterns').append( "<li class=\"list-group-item\" id=\"#{a_layer.id}\">#{a_layer.name}</li>" )
          ),this)

        $("[id^='layer-item-']").on('click', (el) ->
          $("[id^='layer-item-']").removeClass('selected-item')
          $(this).addClass('selected-item')
          return
        )

      if route == 'mission/*action'
        # if action == 'update'
          # # window.router.navigate("#mission/index", {trigger: true})
          # selected_mission_name = $('.list-group-item.selected-item').html()
          # if selected_mission_name != '' and selected_mission_name != undefined
          #   # check exist
          #   selected_mission_name = undefined
          # else
          #   window.appController.flash(message: 'select a layer to delete first!')        
          # window.router.navigate("#mission/index", {trigger: true})
          # return false
          # selected_mission_name = 
          # if one of exist missions has a same name with the to-updated name mission
          # we could not allow it happen.
        if action == 'update'
          window.router.navigate("#mission/index", {trigger: true})
          return false
        
        if action == 'rename'
          selected_mission_name = $('.list-group-item.selected-item').html()
          window.router.navigate("#mission/index", {trigger: true})
          new_message = '<form class="navbar-form"> <div class="form-group"> <input type="text" class="form-control" id="to-renamed-mission" placeholder="'\
            + "#{selected_mission_name}" + '"> </div> <a class="btn btn-default" id="misson_rename">Rename</a> </form>'
          @flash({message: new_message, closable: false})
          $('#misson_rename').click ->
            if ($('#to-renamed-mission').val() != '')
              ## todo
              ## rename the mission after validate it if no same name with exists missions
              console.log "todo -> rename mission in pdl"
            $.modal.close()

          window.router.navigate("#mission/index", {trigger: true})
          return false

        if action == 'index'
          mission_list = window.appController.get_mission_list()
          if mission_list.length > 0
            _.each(mission_list, (a_mission) ->
              $('#mission_list').append("<li class=\"list-group-item mission_item\" >#{a_mission}</li>"))

            $(".mission_item").on('click', (el) ->
              $(".mission_item").removeClass('selected-item')
              $(this).addClass('selected-item')
              return
            )
          return
        if action == 'save'
          window.router.navigate("#mission/index", {trigger: true})
          mission_pairs = _.pairs(window.appController.mission.toJSON())
          _.each(mission_pairs, ((a_pair) ->
            field = a_pair[0]
            value = a_pair[1]
            # mission_data
            # if _.contains(['name','creator','product','company','code'], field)
              # setVarRequest("mission_data.#{field}", value)
            # setting_data

            # layers_data
            field = a_pair[0]
            value = a_pair[1]
            console.log "#{field} -> #{value}"
            ),this)
        if action == 'edit'
          # init avaiable layers
          _.each(@mission.get('available_layers'),((a_layer, index) ->
              console.log index
              $('#my-select').append( "<option value='#{a_layer.name}-----#{Math.random()*10e16}'>#{a_layer.name}</option>" )
            ),this) 
          # init used layers    
          _.each(window.appController.getUsedLayersOrder().reverse(),((a_layer) ->
              $('#my-select').prepend( "<option value=#{a_layer.option_value} selected>#{a_layer.name}</option>" )
            ),this) 

          selection_selector = ".ms-selection li:visible span"
          selectable_selector= ".ms-selectable li:visible span"
          $('#my-select').multiSelect
            
            afterInit: =>
              used_layers = window.appController.getUsedLayersOrder()
              if $(selection_selector) > 1
                $(selection_selector).each (index) ->
                  if index > used_layers.length
                    return false
                  $(this).attr('layer_id', used_layers[index].id)

            afterSelect: (option_value) =>
              @logger.debug "afterSelect: #{option_value}"

              # get select layer value
              regex = /\s*-----\s*/
              selected_layer_info = option_value[0].split(regex)
              selected_layer_name = selected_layer_info[0]
              selected_layer_ulid = @getUlidByName(selected_layer_name)

              # 1. generate new option to selectable layers
              new_option_value = "#{selected_layer_name}-----option#{Math.random()*10e16}"
              $('#my-select').prepend( "<option value='#{new_option_value}'>#{selected_layer_name}</option>" )
              $('#my-select').multiSelect('refresh')

              # 2. add this select layer to used_layers
              console.log "selected_layer_ulid: #{selected_layer_ulid}"
              window.appController.addToUsedLayers(selected_layer_name, option_value[0], selected_layer_ulid)

              # 3. rearrange the order of selectable layers
              available_layers = window.appController.getAvailableLayersOrder()
              @keepLeftOrderForMissionEdit(available_layers,selectable_selector)  

              # 4. keep orgin order, right
              # set new identity after removing old identity
              $(selection_selector).removeAttr('layer_id')
              used_layers = window.appController.getUsedLayersOrder()
              @setSelectedLayerIDForMissionEdit(used_layers,selection_selector) 
              
              # 5. rearrange the order selection layers
              @keepRightOrderForMissionEdit(used_layers,selection_selector)   

              @logger.debug "[afterSelect]: old: #{option_value}"
              @logger.debug "[afterSelect]: new: #{new_option_value}"

              # mission changed
              window.appController.mission_saved_flag = false

              # mission binding by rivets
              rivets.bind $('.mission_'),{mission: window.appController.mission}

              return 
            afterDeselect: (option_value) =>
              @logger.debug "afterDeselect: #{option_value}"
              # remove selected item
              regex = /\s*-----\s*/
              value = option_value[0].split(regex)
              value_name = value[0]

              $("option[value='" + option_value + "']").remove()
              @logger.debug "[afterDeselect]: #{option_value}"
              $('#my-select').multiSelect('refresh')

              ## to keep orgin order
              available_layers = window.appController.getAvailableLayersOrder()
              
              # order_index = 0
              # while order_index < available_layers.length
              #   to_ordered_layer = available_layers[order_index]
              #   selectable_layers.each (index) ->
              #     if $(this).html() == to_ordered_layer
              #       $(this).parent().insertBefore($(selectable_layers[order_index]).parent())
              #       return false
              #   selectable_layers = $(selectable_selector)
              #   order_index++
              @keepLeftOrderForMissionEdit(available_layers,selectable_selector) 

              ## to keep orgin order, right
              ## add name attr for identity
              # remove old identity
              $(selection_selector).removeAttr('layer_id')
              # add identity
              window.appController.removeFromUsedLayers(option_value)
              used_layers = window.appController.getUsedLayersOrder()


              # selection_layers = $(selection_selector)
              # order_index = 0            
              # while order_index < used_layers.length 
              #   to_ordered_layer = used_layers[order_index]
              #   selection_layers.each (index) ->
              #     if $(this).html() == to_ordered_layer.name and $(this).attr('layer_id') == undefined
              #       # console.log "#{$(this).html()}, #{$(this).attr('layer_id')},#{$(this).parent().index()}"
              #       # console.log "order_index: #{order_index}; to_ordered_layer.id: #{to_ordered_layer.id} "
              #       # $(this).parent().insertBefore($(selection_layers[order_index]).parent())
              #       $(this).attr('layer_id', to_ordered_layer.id)
              #       return false
              #   selection_layers = $(selection_selector)
              #   order_index++
              @setSelectedLayerIDForMissionEdit(used_layers,selection_selector)
              ## rearrange
              # to keep selected order, right

              # order_index = 0
              # while order_index < used_layers.length 
              #   to_ordered_layer = used_layers[order_index]
              #   selection_layers.each (index) ->
              #     if $(this).attr('layer_id') == to_ordered_layer.id
              #       $(this).parent().insertBefore($(selection_layers[order_index]).parent())
              #       return false
              #   selection_layers = $(selection_selector)
              #   order_index++
              @keepRightOrderForMissionEdit(used_layers,selection_selector)
              # mission changed
              window.appController.mission_saved_flag = false

              # mission binding by rivets
              rivets.bind $('.mission_'),{mission: window.appController.mission}

              return        


      if route == 'pattern/*action'
        if action == 'edit'
          @load_pattern_data(window.appController.selected_layer)
      
      @logger.debug("[after_action]: window.appController.mission_saved_flag #{window.appController.mission_saved_flag}")
    
    keepLeftOrderForMissionEdit:(layers_ordering,selectors)->
      order_index = 0
      selectable_layers = $(selectors)
      while order_index < layers_ordering.length 
        to_ordered_layer = layers_ordering[order_index]
        selectable_layers.each (index) ->
          # if $(this).attr('layer_id') == to_ordered_layer.id
          if $(this).html() == to_ordered_layer
            $(this).parent().insertBefore($(selectable_layers[order_index]).parent())
            return false
        selectable_layers = $(selectors)
        order_index++  

    setSelectedLayerIDForMissionEdit:(layers_ordering,selectors)->
      order_index = 0      
      selection_layers = $(selectors)      
      while order_index < layers_ordering.length 
        to_ordered_layer = layers_ordering[order_index]
        selection_layers.each (index) ->
          if $(this).html() == to_ordered_layer.name and $(this).attr('layer_id') == undefined
            # console.log "#{$(this).html()}, #{$(this).attr('layer_id')},#{$(this).parent().index()}"
            # console.log "order_index: #{order_index}; to_ordered_layer.id: #{to_ordered_layer.id} "
            # $(this).parent().insertBefore($(selection_layers[order_index]).parent())
            $(this).attr('layer_id', to_ordered_layer.id)
            return false
        selection_layers = $(selectors)
        order_index++

    keepRightOrderForMissionEdit:(layers_ordering,selectors)->
      order_index = 0
      selection_layers = $(selectors) 
      while order_index < layers_ordering.length 
        to_ordered_layer = layers_ordering[order_index]
        selection_layers.each (index) ->
          if $(this).attr('layer_id') == to_ordered_layer.id
            $(this).parent().insertBefore($(selection_layers[order_index]).parent())
            return false
        selection_layers = $(selectors)
        order_index++
      # ul = $(".ms-selection ul")
      # ul.children().each (i, li) ->
      #   ul.prepend li
      #   return

    setBoard: (newBoard) ->
      @board = newBoard

    get_mission_list: ->
      ## ajax todo
      ## get mission list 
      ['mission_1', 'mission_2', 'mission_3']

    getLayers: ->
      @mission.get('available_layers') 

    addLayer: (new_layer) ->
      @mission.addLayer(new_layer)

    saveLayerByID: (layer_data) ->
      # todo validator
      new_layer = @board.saveLayerData(layer_data)
      @addLayer(new_layer)
      # mission changed
      window.appController.mission_saved_flag = false      

    getAvailableLayersOrder: ->
      @mission.getAvailableLayersOrder()

    addToUsedLayers: (layer_name, layer_option_value, layer_ulid)->
      @mission.addToUsedLayers(layer_name, layer_option_value, layer_ulid)

    getUsedLayersOrder: ->
      @mission.getUsedLayersOrder()

    removeLayer: (layer_id) ->
      @mission.removeLayer(layer_id)

      # mission changed
      window.appController.mission_saved_flag = false
        
    removeFromUsedLayers: (layer_option_value) ->
      @mission.removeFromUsedLayers(layer_option_value)

      # mission changed
      window.appController.mission_saved_flag = false

    load_pattern_data: (layer_data)->   
      if layer_data != undefined    
        $('#layer-name').val(layer_data.name)
        _.each(layer_data.boxes, (a_box) ->
          window.appController.board.boxes.createNewBox(a_box)
          )

    getUlidByName: (layer_name) ->
      @mission.getLayerDataByName(layer_name).ulid 

    updateUsedLayersNameByUlid:(new_layer_name, layer_ulid) ->
      @mission.updateUsedLayersNameByUlid(new_layer_name, layer_ulid)
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
            width:    @mission.get('pallet_width')
            height:   @mission.get('pallet_height')
            overhang: @mission.get('overhang_len')

      box  =      
            x:      0 
            y:      0
            width:  @mission.get('box_width') 
            height: @mission.get('box_length')
            minDistance: @mission.get('distance')


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

