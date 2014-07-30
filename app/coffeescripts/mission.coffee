define [
  "jquery"
  "underscore"
  "backbone"
  'logger'
], ($, _, Backbone, aLogger) ->  
  class Mission extends Backbone.Model
    defaults: {
      name: 'MissionName',
      creator: 'Your name',
      product: '',
      company: '',
      code: '', 

      #setting
      frame_line_in_index:  16,
      frame_line_in_position_x: 0,
      frame_line_in_position_y: 0,
      frame_line_in_position_z: 0,
      frame_line_in_position_r: 0,

      frame_line_out_index: 7,
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
      tool_position_r: 0,

      length_wise: false,
      cross_wise: true,
      
      mini_distance:     10,

      pallet_length: 300,
      pallet_width: 200,
      pallet_height: 250,
      pallet_weight: 1000,
      sleepsheet_height: 5,

      tare:           1000,
      max_gross:      800,
      max_height:     600,
      overhang_len:   10,  # the value for overhang
      overhang_wid:   10,
      max_pack:       200,

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
      used_layers_created_number: 0, # for count
    }
    initialize: (params) ->
      @logger = aLogger.create
      @logger.debug "this is in mission"

      @on('all', @validateAttrValue)

    is_real: (value) =>
      result = (rReal.test(@get(attr)) or @get(attr) == 0)
      unless result
        console.log "validateAttrValue: #{attr}value: #{@get(attr)} before: #{@previous(attr)} is_real? #{result}"
      result
        

    validateAttrValue : (event_name) ->

      rInteger = /^\+?[1-9][0-9]*$/
      rReal    = /^([1-9]\d*)(\.{0,1}\d*[1-9])?$/
     
      result = event_name.split(':')
      attr = result[1]

      if attr == undefined
        return

      if _.contains(['name', 'creator', 'product', 'company', 'code'], attr)
        window.appController.set_request("mission_data.#{attr}", @get(attr), 'str')
        return



      # if _.contains(['frame_line_in', 'frame_line_out', 'tool_index'], attr)
      #   if !rInteger.test(@get(attr))
      #     @set(attr,  @previous(attr)) 
      #   return  

      # if attr.search('box_') == 0
      #   if !rInteger.test(@get(attr))
      #     @set(attr,  @previous(attr)) 
      #   return
      if attr.search('position_') > 0 
        if !@is_real
          @set(attr,  @previous(attr))
          return
        if parseFloat(@get(attr)) > 720
            @set(attr,  @previous(attr))
        return

      if attr == 'length_wise' or attr == 'cross_wise'  or attr == 'orient'      
        window.appController.set_request("setting_data.#{attr}", @get(attr).toString())
        return 
      
      if !rInteger.test(@get(attr))
        @set(attr,  @previous(attr)) 

      if attr ==  "box_length" or attr ==  "box_width"
        if parseInt(@get('box_length')) < parseInt(@get('box_width'))
          @logger.debug "#{@get('box_length')} < #{@get('box_width')}"
          @set('box_width',  @previous('box_width')) 
          @set('box_length', @previous('box_length'))  
        else 
          window.appController.set_request("setting_data.#{attr}", @get(attr))
        return


      if attr == 'frame_line_in_index'
        @logger.dev "[mission.coffee]: frame_line_in_index"
        window.appController.set_request('setting_data.frame_line_in_index', window.appController.mission.get('frame_line_in_index'))
        window.appController.send_command('getFrameIn')

        window.appController.get_request('setting_data', (data) =>
          window.appController.mission.load_setting_info(JSON.parse(data)) )
        return

      if attr == 'frame_line_out_index'
        @logger.dev "[mission.coffee]: frame_line_out_index"
        window.appController.set_request('setting_data.frame_line_out_index', window.appController.mission.get('frame_line_out_index'))
        window.appController.send_command('getFrameOut')        
        
        window.appController.get_request('setting_data', (data) =>
          window.appController.mission.load_setting_info(JSON.parse(data)) )

        return

      # others not str attr
      window.appController.set_request("setting_data.#{attr}", @get(attr))

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
      # result.reverse()
    used_layers: ->
      @get("used_layers")
      
    addToUsedLayers: (layer_name, layer_option_value, layer_ulid) ->
      to_updated_used_layers = @get("used_layers") 
      current_number = @get('used_layers_created_number')
      new_used_layer = {name: layer_name, option_value: layer_option_value, id: "#{layer_name}-----#{current_number}-----#{Math.random()*10e16}", ulid: layer_ulid} 
      @set('used_layers_created_number', current_number + 1)
      to_updated_used_layers.push(new_used_layer)
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

    get_total_height: ->
      # @get('used_layers').length * @get('box_height')
      all_layers_name = @getUsedLayersName()
      _.reduce(all_layers_name,((sum, layer_name) ->
        if @getBoxesNumberByLayerName(layer_name) > 0 
          layer_height = @get('box_height')
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

    load_mission_info:(mission_data_from_pdl) =>
      console.log "[load_mission_info]:"
      console.log mission_data_from_pdl
      @set('name',mission_data_from_pdl.name)
      @set('creator',mission_data_from_pdl.creator)
      @set('product',mission_data_from_pdl.product)
      @set('company',mission_data_from_pdl.company)
      @set('code',mission_data_from_pdl.code)

    load_setting_info:(setting_data_from_pdl) =>
      console.log "[mission: load_setting_info]"
      console.log setting_data_from_pdl
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
      @set('tool_position_x',setting_data_from_pdl.tool_position_x)
      @set('tool_position_y',setting_data_from_pdl.tool_position_y)
      @set('tool_position_z',setting_data_from_pdl.tool_position_z)
      @set('tool_position_a',setting_data_from_pdl.tool_position_a)
      @set('tool_position_e',setting_data_from_pdl.tool_position_e)
      @set('tool_position_r',setting_data_from_pdl.tool_position_r)
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
      @set('overhang_len',setting_data_from_pdl.overhang_len)
      @set('overhang_wid',setting_data_from_pdl.overhang_wid)
      @set('max_pack',setting_data_from_pdl.max_pack)

      # console.log "[mission: load_setting_info]"
      # console.log "mission setting:"
      # console.log @attributes

    load_layers_info:(layers_from_pdl) =>


  create: new Mission






