define [
  "jquery"
  "underscore"
  "backbone"
  'logger'
], ($, _, Backbone, aLogger) ->  
  class Mission extends Backbone.Model
    boxes_count = 0

    defaults: {
      name: 'new_mission',
      creator: '',
      product: '',
      company: '',
      code: '', 

      #setting
      frame_line_in_index:  1,
      frame_line_in_position_x: 0,
      frame_line_in_position_y: 0,
      frame_line_in_position_z: 0,
      frame_line_in_position_r: 0,

      frame_line_out_index: 2,
      frame_line_out_position_x: 0,
      frame_line_out_position_y: 0,
      frame_line_out_position_z: 0,
      frame_line_out_position_r: 0,

      box_length: 60,
      box_width:  20,
      box_height: 20,
      box_weight: 10,
      box_per_pick: 1,

      box_x_off:  0,
      box_y_off:  0,
      box_z_off:  0,
      orient: false,

      tool_index: 2,
      tool_position_x: 0,
      tool_position_y: 0,
      tool_position_z: 0,
      tool_position_a: 0,
      tool_position_e: 0,
      tool_position_r: 1,


      tool_name: '',
      tcp_position_x: 1,
      tcp_position_y: 1,
      tcp_position_z: 1,
      tcp_position_a: 1,
      tcp_position_e: 1,
      tcp_position_r: 1,      

      length_wise: false,
      cross_wise: true,
      
      mini_distance: 10,

      pallet_length: 400,
      pallet_width: 300,
      pallet_weight: 1000,
      pallet_height: 100,

      sleepsheet_height: 2,
      tare:           1000,
      max_gross:      800,
      max_height:     800,
      max_pack:       4,
      overhang_len:   10,  # the value for overhang
      overhang_wid:   10,
      

      #       pallet =  
      #       width:    200
      #       height:   250 
      #       overhang: 10

      # box  =      
      #       x:      0 
      #       y:      0
      #       width:  60  
      #       height: 20  
      #       minDistance: 10

      available_layers: {}, # layer_data.id : layer_data
      used_layers: [], # {name: layer_name, id: layer_name_random_name},

      # available_layers_sequence: 1, # for identity of selectable layers
      # used_layers_sequence: 1,      # for identity of selection layers
      used_layers_created_number: 10000, # for count
    }
    initialize: (params) ->
      @logger = aLogger.create
      @logger.debug "this is in mission"

      @on('all', @validateAttrValue)

      # available_layers = @get('available_layers')
      # new_layer  = @compositeALayer('SHEET', [])
      # available_layers[new_layer.id] = new_layer
      # @set('available_layers', available_layers) 

    max_number_of_layers : =>
      5
    max_number_of_used_layers : =>
      8 

    is_real: (attr) =>
      rReal    = /^(\-|\+)?([0-9]+(\.[0-9]+)?)$/
      result = rReal.test(@get(attr))
      unless result
        console.log "validateAttrValue: #{attr}value: #{@get(attr)} before: #{@previous(attr)} is_real? #{result}"
      result
        
    is_int: (attr) =>
      rInt    = /^(\-|\+)?([0-9]+)$/
      result = rInt.test(@get(attr))
      unless result
        console.log "validateAttrValue: #{attr}value: #{@get(attr)} before: #{@previous(attr)} is_real? #{result}"
      result

    is_blank: (attr) =>
      @get(attr) == ''
        
    validate_layers: (options={attr: ''})->
      layer_names = @getAvailableLayersOrder()
      if options.attr == 'count'
        layer_names = @getAvailableLayersOrder()
        return @getAvailableLayersOrder().length < @max_number_of_layers()
      if options.attr == 'name'
        return (options.name != '') and (!_.contains(layer_names, options.name))

      return false

    validate_used_layers:(options={attr: ''}) =>
      if options.attr == 'count'
        number_of_used_layers = _.reduce(@used_layers(),((sum, layer) ->
          if layer.name == 'SHEET'
            sum  
          else
            sum + 1) , 0, this)  

        return number_of_used_layers < @max_number_of_used_layers()

      return false

    validateAttrValue : (event_name) ->
      # return

      rInteger = /^\+?[1-9][0-9]*$/
     
      result = event_name.split(':')
      attr = result[1]

      switch attr
        when undefined
          return
        when 'available_layers'
          return  
        when 'used_layers', 'used_layers_created_number'
          return
        when 'name', 'tool_name'
          if @is_blank(attr)
            @set(attr,  @previous(attr))
            window.appController.flash(message: "[#{attr}] could not be blank!")
          else
            window.appController.set_request(
              name: "mission_data.#{attr}" 
              value: @get(attr)
              type:'str'
            )
        when 'creator', 'product', 'company', 'code'
          window.appController.set_request(
            name: "mission_data.#{attr}" 
            value: @get(attr)
            type:'str'
          )
        when 'tool_position_x', 'tool_position_y', 'tool_position_z', 'tool_position_a', 'tool_position_r', 'tool_position_e'
          if !@is_real(attr)
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(
              name: "setting_data.#{attr}" 
              value: @get(attr)
            )            
            window.appController.routine_request(name: 'setTool')
          return 
        when 'tcp_position_x', 'tcp_position_y', 'tcp_position_z', 'tcp_position_a', 'tcp_position_r', 'tcp_position_e'
          if !@is_real(attr)
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(name: "setting_data.#{attr}", value: @get(attr))
          return 
        # when 'frame_line_in_position_x', 'frame_line_in_position_y', 'frame_line_in_position_z', 'frame_line_in_position_r'
        #   if !@is_real(attr) or parseFloat(@get(attr)) > 720
        #     @set(attr,  @previous(attr))
        #   else 
        #     window.appController.set_request(
        #       name: "setting_data.#{attr}" 
        #       value: @get(attr)
        #     )             
        #     window.appController.routine_request(name: 'setFrameIn')
        #   return
        # when 'frame_line_out_position_x', 'frame_line_out_position_y', 'frame_line_out_position_z', 'frame_line_out_position_r'
        #   if !@is_real(attr) or parseFloat(@get(attr)) > 720
        #     @set(attr,  @previous(attr))
        #   else 
        #     window.appController.set_request(
        #       name: "setting_data.#{attr}" 
        #       value: @get(attr)
        #     ) 
        #     window.appController.routine_request(name: 'setFrameOut')
        #   return 
        when 'length_wise', 'cross_wise', 'orient'       
          window.appController.set_request(
            name: "setting_data.#{attr}"
            value: @get(attr).toString()
            )
          return  
        when 'box_length', 'box_width'
          if !@is_int(attr) or @get(attr) < 1
            @set(attr,  @previous(attr))
          else
            if parseInt(@get('box_length')) < parseInt(@get('box_width'))
              @logger.debug "#{@get('box_length')} < #{@get('box_width')}"
              @set('box_width',  @previous('box_width')) 
              @set('box_length', @previous('box_length'))  
            else 
              window.appController.set_request(
                name: "setting_data.#{attr}"
                value: @get(attr)
                )
          return 
        when 'box_x_off','box_y_off','box_z_off'
          if !@is_int(attr)
            @set(attr,  @previous(attr))  
          else
            window.appController.set_request(
              name: "setting_data.#{attr}"
              value: @get(attr)
              )
        when 'mini_distance', 'sleepsheet_height', 'overhang_len', 'overhang_wid'
          if !@is_int(attr) or @get(attr) < 0
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(
              name: "setting_data.#{attr}"
              value: @get(attr)
              )
        when 'box_height', 'box_weight', 'box_per_pick', 'pallet_length', 'pallet_width', 'pallet_height', 'tare', 'max_gross', 'max_height', 'max_pack'
          if !@is_int(attr) or @get(attr) < 1
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(
              name: "setting_data.#{attr}"
              value: @get(attr)
              )
        when 'frame_line_in_index'
          @logger.dev "[mission.coffee]: frame_line_in_index"

          value_frame_line_in_index = window.appController.mission.get('frame_line_in_index')
          value_frame_line_out_index = window.appController.mission.get('frame_line_out_index')
          if !@is_int(attr) or @get(attr) < 0 or value_frame_line_in_index == value_frame_line_out_index
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(
              name: 'setting_data.frame_line_in_index',
              value: @get('frame_line_in_index')
              )

            window.appController.load_frame_in_data()
          return
        when 'frame_line_out_index'
          @logger.dev "[mission.coffee]: frame_line_out_index"
          value_frame_line_in_index = window.appController.mission.get('frame_line_in_index')
          value_frame_line_out_index = window.appController.mission.get('frame_line_out_index')
          if !@is_int(attr) or @get(attr) < 0 or value_frame_line_in_index == value_frame_line_out_index
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(
              name: 'setting_data.frame_line_out_index',
              value: window.appController.mission.get('frame_line_out_index')
              )

            window.appController.load_frame_out_data()
          return  
        when 'tool_index'
          if !@is_int(attr) or @get(attr) < 0 or  @get(attr) > 30
            @set(attr,  @previous(attr))
          else
            @logger.dev "[mission.coffee]: tool_index"
            window.appController.set_request(name: 'setting_data.tool_index', value: @get('tool_index'))
            window.appController.load_tool_data()

        else
          if !@is_int(attr)
            @set(attr,  @previous(attr))
          else
            window.appController.set_request(
              name: "setting_data.#{attr}"
              value: @get(attr)
              )

    generate_valid_layer_name: (new_layer_name)->
      while ! @validate_layers(attr: 'name', name: new_layer_name)
        new_layer_name = "Layer_#{(Math.random()*10e16).toString().substr(0,5)}"
      new_layer_name

    addLayer: (layer_data) ->
      to_updated_available_layers = @get("available_layers")
      to_updated_available_layers[layer_data.id] = layer_data
      @set('available_layers', to_updated_available_layers) 

    removeLayer: (layer_id) ->
      to_updated_available_layers = @get("available_layers")
      to_deleted_layer_name = to_updated_available_layers[layer_id].name
      delete to_updated_available_layers[layer_id]
      @set('available_layers', to_updated_available_layers)

      to_updated_used_layers = @get("used_layers")
      result = _.reject(to_updated_used_layers, (used_layer) ->
        String(used_layer.name) == String(to_deleted_layer_name)) 
      @set('used_layers', result)

    layers: ->
      @get("available_layers")

    getAvailableLayersOrder: ->
      result = _.map(_.values(@get("available_layers")), (layer) ->
        layer.name) 
      result = _.filter result, (layer_name) ->
              layer_name != 'SHEET'
      # result.reverse()
    used_layers: ->
      @get("used_layers")
      
    addToUsedLayers: (layer_name, layer_option_value, layer_ulid) ->
      to_updated_used_layers = @get("used_layers") 
      current_number = @get('used_layers_created_number')
      new_used_layer = {name: layer_name, option_value: layer_option_value, id: "#{layer_name}-----#{current_number}-----#{Math.random()*10e16}", ulid: layer_ulid} 
      @set('used_layers_created_number', current_number + 1)
      to_updated_used_layers.push(new_used_layer)
      @set('used_layers', to_updated_used_layers)
    removeFromUsedLayers: (layer_option_value) ->
      to_updated_used_layers = @get("used_layers") 
      result = _.reject(to_updated_used_layers, (used_layer) ->
        String(used_layer.option_value) == String(layer_option_value)) 
      @logger.debug "used_layer_length: #{result.length}"
      @set('used_layers', result)

    getUsedLayersOrder: ->
      @get('used_layers')

    # for statistics in page mission edit
    getUsedLayersName: ->
      _.map @used_layers(), (a_used_layer) ->
        a_used_layer.name
    getLayerDataByName:(layer_name) ->
      all_layers = _.values(@layers())
      _.find(all_layers, (a_layer) ->
        a_layer.name == layer_name) 
    
    updateUsedLayersNameByUlid:(new_layer_name, layer_ulid) ->
      to_updated_used_layers = @get("used_layers") 
      result = _.map(to_updated_used_layers, (used_layer) ->
        if layer_ulid == used_layer.ulid
          used_layer.name = new_layer_name
          used_layer
        else
          used_layer)
      @set('used_layers', result)  
  
    getBoxesNumberByLayerName: (layer_name) ->
      boxes_number = @getLayerDataByName(layer_name).boxes.length
      if boxes_number != undefined
        boxes_number
      else
        0

    get_total_height: =>
      all_layers_name = @getUsedLayersName()
      _.reduce(all_layers_name,((sum, layer_name) ->
        if @getBoxesNumberByLayerName(layer_name) > 0 
          layer_height = Number.parseInt(@get('box_height'))
        else if layer_name == 'SHEET'
          layer_height = Number.parseInt(@get('sleepsheet_height'))
        else
          layer_height = 0
        sum + layer_height), 0, this)
    get_total_box: ->
      all_layers_name = @getUsedLayersName()
      _.reduce(all_layers_name,((sum, layer_name) ->
        sum + @getBoxesNumberByLayerName(layer_name)), 0, this)

    get_total_weight: ->
      all_layers = @getUsedLayersName()
      box_weight = @get('box_weight')
      _.reduce(all_layers,((sum, layer_name) ->
        sum + box_weight * @getBoxesNumberByLayerName(layer_name)), 0, this) 

    get_total_block_dim: -> 
      all_layers = @getUsedLayersName()
      _.reduce(all_layers,((sum, layer_name) ->
        sum + @getBoxesNumberByLayerName(layer_name)), 0, this)

    get_count_of_sheets : =>
      _.reduce(@used_layers(),((sum, layer) ->
        if layer.name == 'SHEET'
          sum + 1 
        else
          sum) , 0, this)

    get_count_of_layers : =>
      @getAvailableLayersOrder().length

    load_mission_info:(mission_data_from_pdl) =>
      # console.log "[load_mission_info]:"
      # console.log mission_data_from_pdl
      @set('name',mission_data_from_pdl.name)
      @set('creator',mission_data_from_pdl.creator)
      @set('product',mission_data_from_pdl.product)
      @set('company',mission_data_from_pdl.company)
      @set('code',mission_data_from_pdl.code)

    load_setting_info:(setting_data_from_pdl) =>
      # console.log "[mission: load_setting_info]"
      # console.log setting_data_from_pdl
      @set('frame_line_in_index',setting_data_from_pdl.frame_line_in_index)
      @set('frame_line_in_position_x',setting_data_from_pdl.frame_line_in_position_x)
      @set('frame_line_in_position_y',setting_data_from_pdl.frame_line_in_position_y)
      @set('frame_line_in_position_z',setting_data_from_pdl.frame_line_in_position_z)
      @set('frame_line_in_position_r',setting_data_from_pdl.frame_line_in_position_r)
      @set('frame_line_out_index',setting_data_from_pdl.frame_line_out_index)
      @set('frame_line_out_position_x',setting_data_from_pdl.frame_line_out_position_x)
      @set('frame_line_out_position_y',setting_data_from_pdl.frame_line_out_position_y)
      @set('frame_line_out_position_z',setting_data_from_pdl.frame_line_out_position_z)
      @set('frame_line_out_position_r',setting_data_from_pdl.frame_line_out_position_r)
      @set('box_length',setting_data_from_pdl.box_length)
      @set('box_width',setting_data_from_pdl.box_width)
      @set('box_height',setting_data_from_pdl.box_height)
      @set('box_weight',setting_data_from_pdl.box_weight)
      @set('box_per_pick',setting_data_from_pdl.box_per_pick)
      @set('box_x_off',setting_data_from_pdl.box_x_off)
      @set('box_y_off',setting_data_from_pdl.box_y_off)
      @set('box_z_off',setting_data_from_pdl.box_z_off)
      @set('orient',setting_data_from_pdl.orient)
      @set('tool_index',setting_data_from_pdl.tool_index)
      @set('tool_name',setting_data_from_pdl.tool_name)
      @set('tool_position_x',setting_data_from_pdl.tool_position_x)
      @set('tool_position_y',setting_data_from_pdl.tool_position_y)
      @set('tool_position_z',setting_data_from_pdl.tool_position_z)
      @set('tool_position_a',setting_data_from_pdl.tool_position_a)
      @set('tool_position_e',setting_data_from_pdl.tool_position_e)
      @set('tool_position_r',setting_data_from_pdl.tool_position_r)
      @set('tcp_position_x',setting_data_from_pdl.tcp_position_x)
      @set('tcp_position_y',setting_data_from_pdl.tcp_position_y)
      @set('tcp_position_z',setting_data_from_pdl.tcp_position_z)
      @set('tcp_position_a',setting_data_from_pdl.tcp_position_a)
      @set('tcp_position_e',setting_data_from_pdl.tcp_position_e)
      @set('tcp_position_r',setting_data_from_pdl.tcp_position_r)
      @set('length_wise',setting_data_from_pdl.length_wise)
      @set('cross_wise',setting_data_from_pdl.cross_wise)
      @set('pallet_length',setting_data_from_pdl.pallet_length)
      @set('pallet_width',setting_data_from_pdl.pallet_width)
      @set('pallet_height',setting_data_from_pdl.pallet_height)
      @set('pallet_weight',setting_data_from_pdl.pallet_weight)
      @set('sleepsheet_height',setting_data_from_pdl.sleepsheet_height)
      @set('tare',setting_data_from_pdl.tare)
      @set('max_gross',setting_data_from_pdl.max_gross)
      @set('max_height',setting_data_from_pdl.max_height)
      @set('mini_distance',setting_data_from_pdl.mini_distance)
      @set('overhang_len',setting_data_from_pdl.overhang_len)
      @set('overhang_wid',setting_data_from_pdl.overhang_wid)
      @set('max_pack',setting_data_from_pdl.max_pack)

      # console.log "[mission: load_setting_info]"
      # console.log "mission setting:"
      # console.log @attributes

    load_layers_info:(layers_from_pdl) =>

      @set('available_layers', {})
      # {
      #   "layers": [{
      #       "name": "layer_1",
      #       "is_available": true
      #     }, {
      #       "name": "layer_2",
      #       "is_available": true
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }]
      # }

      boxes = {} # by layer_name

      available_layers_names = _.select(layers_from_pdl.layers, ((a_layer) => 
        a_layer.is_available == true), this)

      available_layers_names = _.map(available_layers_names, ((a_layer) =>
        a_layer.name), this)

      for a_layer in available_layers_names
        boxes[a_layer] = []


      window.appController.routine_request(name: 'countOfBoxes', params: [''])
      window.appController.get_request(
        name: 'temp_boxes_count'
        callback: (data) =>
          @boxes_count = Number.parseInt(data))


      for i in [1..@boxes_count] by 1
        window.appController.routine_request(
          name: 'findBox'
          params: [i, '']
          )
        window.appController.get_request(
          name: 'request_box'
          callback: (data) ->
            box= JSON.parse(data)
            boxes[box.layer_name].push(box) if box.is_available && boxes[box.layer_name] != undefined)


      for a_layer_name in available_layers_names
        available_layers = @get('available_layers') 
        new_layer  = @compositeALayer(a_layer_name, boxes[a_layer_name])
        available_layers[new_layer.id] = new_layer
        @set('available_layers', available_layers)

        used_layers = @get('used_layers')




    load_used_layers_info:(used_layers_from_pdl) => 
      @set('used_layers', [])
      # {
      #   "used_layers":  [{
      #       "name": "layer_1",
      #       "is_available": true
      #     }, {
      #       "name": "layer_1",
      #       "is_available": true
      #     }, {
      #       "name": "layer_1",
      #       "is_available": true
      #     }, {
      #       "name": "layer_2",
      #       "is_available": true
      #     }, {
      #       "name": "layer_1",
      #       "is_available": true
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }, {
      #       "name": "",
      #       "is_available": false
      #     }]
      # }

      used_layers_name = _.select(used_layers_from_pdl.used_layers, ((a_layer) =>
        a_layer.is_available == true), this)

      used_layers_name = _.map(used_layers_name, ((a_layer) =>
        a_layer.name), this)

      used_layers = []
      for a_layer_name  in used_layers_name
        new_used_layer =  @compositeAUsedLayer(a_layer_name) 
        used_layers.push(new_used_layer)
      
      @set('used_layers', used_layers)
      
    compositeALayer: (layer_name, layer_boxes) =>
      # available_layer will be used it after getting the data from pdl
      # the key of layer is id


      # boxes: Array[8]
      # id: "layer-item-1111-238756119273602980"
      # name: "1111"
      # ulid: "1111------ulid991697110701352300"
      new_layer  = 
        name: layer_name
        boxes: layer_boxes
        id: "layer-item-#{layer_name}-#{Math.random()*10e16}"
        ulid: "#{layer_name}------ulid#{Math.random()*10e17}"

    compositeAUsedLayer: (layer_name) =>
      # id: "ddddd-----10001-----27212137775495650"
      # name: "ddddd"
      # option_value: "ddddd-----option3679642337374389"
      # ulid: "ddddd------ulid64922175602987410"
      new_used_layer =
        id: "#{layer_name}-----#{@get('used_layers').length}-----#{Math.random()*10e16}"
        name: layer_name
        option_value: "#{layer_name}-----option#{Math.random()*10e16}"
        ulid: window.appController.getUlidByName(layer_name)


    generateCSVData: ->
      window.appController.routine_request(name: 'resetCSVFile', params: ["#{@get('name')}.csv"])

      # 2.2.0.23;gianni;18.06.14_14.51;asd;sd
      # "pallet";EURO-Palette;1200;800;145;30
      # "sheet";5;0
      # "pall_info";198;18;30;1200;800;1585
      # "tool";simulazio;0;0;1;-135;0;32;0;0;0;0
      # "linein";Conveyor;1;0
      # "lineout";Pallet place definition;0;0
      # "pack";gianni;310;260;80;0;0;0;0
      @pprint "_versionOfMultipck;#{@get('name')};#{@get('creator')};#{@get('company')}"
      @pprint "\"pallet\";_description;#{@get('pallet_length')};#{@get('pallet_width')};#{@get('pallet_height')};#{@get('tare')}"
      @pprint "\"sheet\";#{@get('sleepsheet_height')};#{@get_count_of_sheets()}"
      @pprint "\"pall_info\";#{@get_total_box()};#{@get_count_of_layers()};#{@get_total_weight()};#{@get('pallet_length')};#{@get('pallet_width')};#{@get('pallet_height')}"
      @pprint "\"tool\";#{@get('tool_name')};0;0;0;#{@get('tool_position_x')};#{@get('tool_position_y')};#{@get('tool_position_z')};0;0;0;0"
      @pprint "\"linein\";Conveyor;#{@get('frame_line_in_index')};0;"
      @pprint "\"lineout\";Pallet place definition;#{@get('frame_line_out_index')};0;"
      @pprint "\"pack\";#{@get('product')};#{@get('box_length')};#{@get('box_width')};#{@get('box_height')};#{@get('box_weight')};0;0;0"
      @pprint "010000"
      @pprint "120000"
      @pprint "220000"


      all_layers = @getUsedLayersName()
      packageSequence = 1
      layerNO = 1


      packages = new Array(@get('box_per_pick'))
      index_ = 0
      while index_ < packages.length
        packages[index_] = 1
        index_ += 1
      
      gripperStatus = packages.join(' ')
      gripperAfterStatus = _.map(packages,(el) ->
        0).join(' ')
      
      gripperStatus = _.map(new Array(@get('box_per_pick')), (el) ->
        1).join(' ')
      gripperAfterStatus = _.map(new Array(@get('box_per_pick')), (el) ->
        0).join(' ')
      for a_layer_name in all_layers
        packageSequenceInLayer = 1

        a_layer = @getLayerDataByName(a_layer_name)
        boxes_in_a_layer = a_layer.boxes
        for a_box in boxes_in_a_layer
          if a_box.arrowEnabled
            switch a_box.arrow
              when 0
                # @moveByX(0)
                # @moveByY(1)
                insert_angle = '0 1'
              when 45
                # @moveByX(1)
                # @moveByY(1)
                insert_angle = '1 1'
              when 90
                # @moveByX(1)
                # @moveByY(0)
                insert_angle = '1 0'
              when 135
                # @moveByX(1)
                # @moveByY(-1)
                insert_angle = '1 -1'
              when 180
                # @moveByX(0)
                # @moveByY(-1)
                insert_angle = '0 -1'
              when 225
                # @moveByX(-1)
                # @moveByY(-1)
                insert_angle = '-1 -1'
              when 270
                # @moveByX(-1)
                # @moveByY(0)
                insert_angle = '-1 0'
              when 315
                # @moveByX(-1)
                # @moveByY(1)
                insert_angle = '-1 1'
              when 360
                # @moveByX(0)
                # @moveByY(1)
                insert_angle = '0 1'
          else
            insert_angle = '0 0' 

           
          @pprint "100101;#{@get('box_per_pick')};#{@get('tcp_position_x')};#{@get('tcp_position_y')};#{@get('tcp_position_z')};#{@get('tcp_position_r')};#{gripperStatus};#{packageSequence};0;0;0"
          @pprint "200101;#{a_box.x};#{a_box.y};#{@get('box_height') * layerNO};__tcpRZ;#{insert_angle};#{gripperStatus};#{gripperAfterStatus};0;#{packageSequence};#{layerNO};#{packageSequenceInLayer};1;0;0;0"

          packageSequence += 1
          packageSequenceInLayer += 1
    pprint: (str) ->
      window.appController.routine_request(name: 'writeCSVFile', params: ["#{@get('name')}.csv","#{str}"])
  create: new Mission






