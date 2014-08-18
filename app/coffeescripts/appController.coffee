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

      # @remote_url = 'http://192.168.56.2/'
      # @remote_url = 'http://172.22.117.53/'
      # @remote_url = 'http://192.168.1.103:4242/'
      @remote_url = 'http://127.0.0.1:8000/'
      @program_name = 'pd_db2'

      @mission_saved_flag = true
      @pattern_saved_flag = true

      # mission index page
      @mission_list = []

      #
      # get boxes from pdl
      #

      @temp_boxes_count = 0
  

      # interval of request
      # @request_body = undefined
    # http://192.168.56.2/set?var=gui_string&prog=gui_example_test_2&value=%27ddddd%27
    # getVarRequest: (varName, callback) ->
    #   get_url = "get?var=" + varName + "&prog=" + programName
    #   $.ajax
    #     url: get_url
    #     cache: false
    #     dataType: 'JSONP'
    #     success: (data) ->
    #       callback data
    #       return
    #     done: () ->
    #       window.appController.logger.dev "[get]: #{get_url}"
    #     error: () ->
    #       window.appController.logger.dev "[get]: error"
    #   return

    # setVarRequest: (varName, newVarValue, callback) ->
    #   set_url = "set?var=" + varName + "&prog=" + programName + "&value=" + newVarValue
    #   $.ajax
    #     url: set_url
    #     cache: false
    #     dataType: 'JSONP'
    #     success: (data) ->
    #       callback data, varName
    #       return 
    #     done: () ->
    #       window.appController.logger.dev "[set]: #{set_url}"
    #     error: () ->
    #       window.appController.logger.dev "[set]: error"
    #   return

    sleep: (d = 100) ->
      t = Date.now()
      while Date.now() - t <= d
        d

    #
    #  ajax request to pdl sever
    #
    set_request: (options) =>
      if options.type == 'str'
        options.value = "'#{ options.value}'"  

      get_url = "set?var=#{options.name}&prog=#{@program_name}&value=#{options.value}"
      console.log "#{@remote_url}#{get_url}"

      $.ajax
        url: get_url
        cache: false
        async: false
        success: (data) ->
          options.callback data if options.callback != undefined
        error: () ->
          window.appController.logger.dev "[set]: error"        
        
    get_request: (options) =>
      get_url = "get?var=#{options.name}&prog=#{@program_name}"
      console.log "#{@remote_url}#{get_url}"
      $.ajax
        url: get_url
        cache: false
        async: false
        success: (data) ->
          options.callback data if options.callback != undefined
        error: () ->
          window.appController.logger.dev "[get]: error" 
    
    get_mission_list: =>
      get_url = "get?dirList=UD:/usr/dev/"
      console.log "#{@remote_url}#{get_url}"

      $.ajax
        url: get_url
        cache: false
        async: false
        success: (data) ->
          window.appController.mission_list = JSON.parse(data)
        error: () ->
          window.appController.logger.dev "[get_mission_list]: error" 

    routine_request: (options) =>
      params = options.params
      if params != undefined 
        params_ = _.map(params, (param)->
          if typeof(param) == 'string'
            "'#{param}'" 
          else
            param
          )
        result = "(#{params_.join(',')})"
      else
        result = ''

      get_url = "run?routine=#{options.name}#{result}&prog=#{@program_name}"
      console.log "#{@remote_url}#{get_url}"
      $.ajax
        url: get_url
        cache: false
        async: false
        success: (data) ->
          options.callback data if options.callback != undefined
        error: () ->
          window.appController.logger.dev "[get]: error" 
    
    load_mission_data: (mission_data_name) => 

      @mission.set('available_layers', {})
      @mission.set('used_layers', [])

      @routine_request(
        name: 'loadVarFile'
        params: [mission_data_name])

      @get_request(
        name: 'mission_data'
        callback: (data) ->
          window.appController.mission.load_mission_info(JSON.parse(data)) )
      
      @get_request(
        name:'setting_data'
        callback: (data) ->
          window.appController.mission.load_setting_info(JSON.parse(data)) )

      @get_request(
        name: 'layers'
        callback: (data) ->
          window.appController.mission.load_layers_info(JSON.parse(data))
      )    
      @get_request(
        name: 'used_layers'
        callback: (data) ->
          window.appController.mission.load_used_layers_info(JSON.parse(data)) 
      )

    load_frame_data: =>  
      @set_request(
        name: 'setting_data.frame_line_in_index'
        value: @mission.get('frame_line_in_index')
      )

      @routine_request(name: 'getFrameIn')

      @get_request(
        name: 'setting_data'
        callback: (data) =>
          @mission.load_setting_info(JSON.parse(data))
      )

      @set_request(
        name: 'setting_data.frame_line_out_index'
        value: @mission.get('frame_line_out_index')
      )

      @routine_request(name: 'getFrameOut')

      @get_request(
        name: 'setting_data'
        callback: (data) =>
          @mission.load_setting_info(JSON.parse(data))
      )  

    load_tool_data: =>
        @set_request(name: 'setting_data.tool_index', value: @mission.get('tool_index'))
        @routine_request(name: 'getTool')

        @get_request(
          name:'setting_data'
          callback: (data) ->
            window.appController.mission.load_setting_info(JSON.parse(data)) )

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
        
      # get mission list data    
      @get_mission_list()

      if route == 'mission/*action'
        if action == 'new'
          if window.appController.mission_saved_flag == true
            @mission = @new_mission
          else
            @flash({message: 'Do you want to abandon the modification?'})
            window.router.navigate("#program", {trigger: true})
            return false
        if action == 'save'
          @flash(message: 'Saving Data......', closable: false)

        if action == 'save_as'
          new_message = '<form class="navbar-form"> <div class="form-group"> <input type="text" class="form-control" id="to-renamed-mission" placeholder="'\
            + "#{selected_mission_name}" + '"> </div> <a class="btn btn-default" id="misson_rename">Rename</a> </form>'          
          @flash(message: 'Saving Data......', closable: false)

      if route == 'frame'
        @load_frame_data()

      if route == 'pattern/*action'
        if action == 'new'
          unless @mission.validate_layers(attr: 'count')
            window.router.navigate("#patterns", {trigger: true} )
            @flash(message: 'Reach the maximam number of Pattern!', closable: true)
            return false
    after_action: (route, params) =>
      action = params[0]
      rivets.bind $('.mission_'),{mission: @mission}

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
          window.appController.mission.set('length_wise', state)
          $("[name='cross']").bootstrapSwitch('state', !state) 

        
        cross_wise_value = window.appController.mission.get('cross_wise')
        $("[name='cross']").bootstrapSwitch('state', cross_wise_value) 
        $("[name='cross']").on "switchChange.bootstrapSwitch", (event, state) ->
          window.appController.mission.set('cross_wise', state)
          $("[name='length']").bootstrapSwitch('state', !state) 
      
      if route == 'patterns'
        layers = _.values(@mission.get('available_layers'))
        for a_layer in layers
          # SHEET  are layers can not access
          if a_layer.name != 'SHEET'
            $('#patterns').append( "<li class=\"list-group-item\" id=\"#{a_layer.id}\">#{a_layer.name}</li>" )
  
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
        if action == 'delete'
          @get_mission_list()
          selected_mission_name = $('.list-group-item.selected-item').html()
          if _.contains(@mission_list, "#{selected_mission_name}.var")
            @routine_request(name: 'deleteVarFile', params: [selected_mission_name])
          else
            @flash("#{selected_mission_name} does not exist!", close: true)
          window.router.navigate("#mission/index", {trigger: true})
          return false
        

        if action == 'rename'
          selected_mission_name = $('.list-group-item.selected-item').html()
          if selected_mission_name == undefined
            window.router.navigate("#mission/index", {trigger: true})
            return false

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
          $('a[href="#mission/load"]').click ->
            window.appController.flash(message: 'Loading Data...', closable: false)
          @get_mission_list()
          if @mission_list.length > 0
            _.each(window.appController.mission_list, (a_mission) ->
              r_var_file = /\w+\.var$/
              if r_var_file.test(a_mission)
                $('#mission_list').append("<li class=\"list-group-item mission_item\" >#{a_mission.substring(0,a_mission.length-4)}</li>"))

            $(".mission_item").on('click', (el) ->
              $(".mission_item").removeClass('selected-item')
              $(this).addClass('selected-item')
            )

        if action == 'save'
          
          mission_pairs = _.pairs(window.appController.mission.toJSON())

          #
          # in validate, single variable have been saved to pdl programe.
          # so we need to do save composite variables like layers data in here.
          #

          @routine_request(name: 'resetBoxes')
          @routine_request(name: 'resetLayers')
          @routine_request(name: 'resetUsedLayers')

          _.each(mission_pairs, ((a_pair) ->
            field = a_pair[0]
            value = a_pair[1]

            if _.contains(['available_layers', 'used_layers', 'used_layers_created_number'], field)
              # console.log field
              # console.log value
              if field == 'available_layers'
                @sendLayersToSave()
              if field == 'used_layers'
                @sendUsedLayersToSave()
              # to do
            ),this)

          @routine_request(name: 'saveVarFile', params:[@mission.get('name')])
          @mission.generateCSVData()
          @get_mission_list()
          
          window.appController.sleep(1000)
          $.modal.close()
          window.router.navigate("#program", {trigger: true})
        if action == 'edit'
          # init avaiable layers
          # destroy all data in multi_select
          $('.ms-list').empty()
          $('#my-select').empty()

          _.each(@mission.get('available_layers'),((a_layer, layer_index) ->
            $('#my-select').append( "<option value='#{a_layer.name}-----#{Math.random()*10e16}'>#{a_layer.name}</option>" )
            ),this) 

          $('#my-select').prepend( "<option value='PALLET' selected>0: PALLET</option>" )
          _.each(window.appController.getUsedLayersOrder(),((a_layer, layer_index) ->
              $('#my-select').prepend( "<option value=#{a_layer.option_value} layer-index='#{layer_index}' selected>#{layer_index+1}: #{a_layer.name}</option>" )
            ),this) 

          $('#my-select').multiSelect
            afterSelect: (option_value) =>
              @logger.debug "afterSelect: #{option_value}"

              # get select layer value
              regex = /\s*-----\s*/
              selected_layer_info = option_value[0].split(regex)
              selected_layer_name = selected_layer_info[0]
              selected_layer_ulid = @getUlidByName(selected_layer_name)

              window.appController.addToUsedLayers(selected_layer_name, option_value[0], selected_layer_ulid)

              @refreshSelectableAndSelectedLayers()

              # mission changed
              window.appController.mission_saved_flag = false

              # mission binding by rivets
              rivets.bind $('.mission_'),{mission: window.appController.mission}
 
            afterDeselect: (option_value) =>
              @logger.debug "afterDeselect: #{option_value}"
              # remove selected item
              regex = /\s*-----\s*/
              value = option_value[0].split(regex)
              value_name = value[0]

              # to_remove_used_layer_index = $("option[value='" + option_value + "']").attr('layer-index')

              window.appController.removeFromUsedLayers(option_value)


              @refreshSelectableAndSelectedLayers()


              window.appController.mission_saved_flag = false

              # mission binding by rivets
              rivets.bind $('.mission_'),{mission: window.appController.mission}

        if action == 'load'
          selected_mission_name = $('.list-group-item.selected-item').html()
          if selected_mission_name != undefined
            @mission.set('name', selected_mission_name)
            console.log "selected_mission_name: #{selected_mission_name}"
            console.log "@mission.get('name'): #{@mission.get('name')}"

            console.log "----->before: load_mission_data"
            @load_mission_data(selected_mission_name)
            console.log "----->after: load_mission_data"

            $.modal.close()
            window.router.navigate("#program", {trigger: true})
            rivets.bind $('.mission_'),{mission: @mission} 
            return false 

          $.modal.close();
          window.router.navigate("#mission/index", {trigger: true})
          return false 

        if action == 'reload'
          @get_mission_list()
          to_reload_mission_name = "#{@mission.get('name')}.var"
          if _.contains(@mission_list, to_reload_mission_name)
            @routine_request(name: 'loadVarFile', params: [to_reload_mission_name])
            console.log "----->before: reload_mission_data"
            @load_mission_data(selected_mission_name)
            console.log "----->after: reload_mission_data"
          else
            @flash(message: "[#{@mission.get('name')}] does not exist in ROBOT!", close: true)
          window.router.navigate("#program", {trigger: true})
          return false 

      if route == 'pattern/*action'
        if action == 'edit'
          @load_pattern_data(window.appController.selected_layer)

        if action == 'clone'
          layers = window.appController.getLayers()
          selected_layer_id = $('.list-group-item.selected-item').attr('id')
          selected_layer = layers[selected_layer_id]

          if Object.keys(layers).length != 0 and selected_layer_id != undefined and selected_layer != undefined
            # clone it as a new one before renaming this layer
            clone_layer_name = "#{selected_layer.name}_clone" 
            window.appController.saveLayerByID({name: clone_layer_name})

          window.router.navigate("patterns", {trigger: true})
          return false 

        if action == 'save'
          @logger.debug "route-save"
          @logger.debug "previous_action.action #{window.appController.previous_action.action}"
          @logger.debug "current_action.action #{window.appController.current_action.action}"
          if window.appController.previous_action.action == 'edit'
            window.appController.saveLayerByID({id: window.appController.selected_layer.id, ulid: window.appController.selected_layer.ulid})
            
            # if layer name was modified, then update the layers and used_layers of mission
            # referring to the ulid of this layer.
            new_name = $('#layer-name').val()
            window.appController.updateUsedLayersNameByUlid(new_name, window.appController.selected_layer.ulid)
            window.appController.selected_layer = undefined

          else
            window.appController.saveLayerByID()
          window.router.navigate("patterns", {trigger: true})

      if route == 'frame'
        $("input[rv-value*='position']").attr "readonly", true

      rivets.bind $('.mission_'),{mission: @mission}    


      if route == 'toolSetting'
        $("input").attr "readonly", true
        $("input#table-index").attr "readonly", false
        
        $("[name='teach']").on "switchChange.bootstrapSwitch", (event, state) ->
          # console.log this # DOM element
          # console.log event # jQuery event
          # console.log state # true | false

          # state turn to be off, then button 'set' turn to be button 'PLACE'
          if state
            # ...
            $('a.teach').removeClass('label-primary')
            $('a.teach').addClass('label-success')
            $('a.teach').html('')
            # $("a.teach").attr("href", "#getTool")
            $("input").attr "readonly", true
            $("input#table-index").attr "readonly", false
          else
            # ...
            $('a.teach').removeClass('label-success')
            $('a.teach').addClass('label-success')
            $('a.teach').html('Place')
            $("a.teach").attr("href", "#tool/set")
            $("input").attr "readonly", false

        @load_tool_data()     

        rivets.bind $('.mission_'),{mission: @mission}  


      if route == 'pickSetting'
        $("input").attr "readonly", true
        $("input#table-index").attr "readonly", false
        
        $("[name='teach']").on "switchChange.bootstrapSwitch", (event, state) ->
          # console.log this # DOM element
          # console.log event # jQuery event
          # console.log state # true | false

          # state turn to be off, then button 'set' turn to be button 'PLACE'
          if state
            # ...
            $('a.teach').removeClass('label-primary')
            $('a.teach').addClass('label-success')
            $('a.teach').html('')
            # $("a.teach").attr("href", "#getTool")
            $("input").attr "readonly", true
            $("input#table-index").attr "readonly", false
          else
            # ...
            $('a.teach').removeClass('label-success')
            $('a.teach').addClass('label-success')
            $('a.teach').html('Place')
            $("a.teach").attr("href", "#tool/set")
            $("input").attr "readonly", false

        @load_tool_data()     

        rivets.bind $('.mission_'),{mission: @mission}     


      if route == 'tool/*action' 
        if action == 'set'   
          @routine_request(name: 'setTool')
          window.router.navigate("#pickSetting", {trigger: true})
          rivets.bind $('.mission_'),{mission: @mission} 
          return false 

      @logger.debug("[after_action]: window.appController.mission_saved_flag #{window.appController.mission_saved_flag}")
    

    # functions for mission edit page

    refreshSelectableAndSelectedLayers: ->
      # destroy all data in multi_select
      $('.ms-list').empty()
      $('#my-select').empty()


      _.each(@mission.get('available_layers'),((a_layer, layer_index) ->
        $('#my-select').append( "<option value='#{a_layer.name}-----#{Math.random()*10e16}'>#{a_layer.name}</option>" )
        ),this) 

      $('#my-select').prepend( "<option value='PALLET' selected>0: PALLET</option>" )
      _.each(window.appController.getUsedLayersOrder(),((a_layer, layer_index) ->
          $('#my-select').prepend( "<option value=#{a_layer.option_value} layer-index='#{layer_index}' selected>#{layer_index+1}: #{a_layer.name}</option>" )
        ),this) 

      $('#my-select').multiSelect('refresh')   


    setBoard: (newBoard) ->
      @board = newBoard

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

    #
    # generate layers data to save data from js to pdl
    #

    sendLayersToSave: =>
      available_layers = @mission.get('available_layers')
  
      _.each(available_layers, ((a_layer) =>
        layer_name = a_layer.name
        layer_boxes = a_layer.boxes

        @routine_request(
          name: 'addNewLayer'
          params:[layer_name]
        )

        _.each(layer_boxes, ((a_box) =>
          @set_request(name: 'request_box.x', value: a_box.x)
          @set_request(name: 'request_box.y', value: a_box.y)
          @set_request(name: 'request_box.arrow', value: a_box.arrow)
          @set_request(name: 'request_box.arrowEnabled', value: a_box.arrowEnabled.toString())
          @set_request(name: 'request_box.layer_name', value: layer_name, type: 'str')
          @set_request(name: 'request_box.rotate', value: a_box.rotate)  
          @routine_request(name: 'addNewBox')          
          ), this)
        ), this)

    sendUsedLayersToSave: =>
      used_layers = @mission.get('used_layers')
 
      _.each(used_layers, ((a_layer) =>
        @routine_request(name: 'addNewUsedLayer', params:[a_layer.name])
        ), this)      
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
            width:    @mission.get('pallet_length')
            height:   @mission.get('pallet_width')
            overhang: @mission.get('overhang_len')

      box  =      
            x:      0 
            y:      0
            width:  @mission.get('box_length') 
            height: @mission.get('box_width')
            minDistance: @mission.get('mini_distance')


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

