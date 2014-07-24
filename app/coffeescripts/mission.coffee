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
      frame_line_in:  0,
      frame_line_in_position_x: 0,
      frame_line_in_position_y: 0,
      frame_line_in_position_z: 0,
      frame_line_in_position_r: 0,

      frame_line_out: 0,
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
      
      distance:     10,

      pallet_length: 300,
      pallet_width: 200,
      pallet_height: 250,
      pallet_weight: 1000,
      sleepsheet_height: 5,

      tare:           1000,
      max_gross:      800,
      max_height:     600,
      overhang_len:   10,
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

    validateAttrValue : (event_name) ->
      rInteger = /^\+?[1-9][0-9]*$/
      rReal    = /^([1-9]\d*)(\.{0,1}\d*[1-9])?$/
     
      result = event_name.split(':')
      attr = result[1]
      console.log "validateAttrValue: #{event_name} #{attr}"

      if attr == undefined
        return

      if _.contains(['name', 'creator', 'product', 'company', 'code'], attr)
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
        if !rReal.test(@get(attr))  
          @set(attr,  @previous(attr))
          return
        if parseFloat(@get(attr)) > 720
            @set(attr,  @previous(attr))
        return

      if attr == 'length_wise' or attr == 'cross_wise'  or attr == 'orient'      
        return 
      
      if !rInteger.test(@get(attr))
        @set(attr,  @previous(attr)) 

      if attr ==  "box_length" or attr ==  "box_width"
        if parseInt(@get('box_length')) < parseInt(@get('box_width'))
          console.log "#{@get('box_length')} < #{@get('box_width')}"
          @set('box_width',  @previous('box_width')) 
          @set('box_length', @previous('box_length'))    

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
  create: new Mission