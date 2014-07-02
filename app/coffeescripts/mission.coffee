define [
  "jquery"
  "underscore"
  "backbone"
  'logger'
], ($, _, Backbone, aLogger) ->  
	class Mission extends Backbone.Model
	  defaults: {

			setting:{
				frame_line_in: '',
				frame_line_out: '',
				box_length: '',
				box_width: '',
				box_height: '',
				box_weight: '',
				box_x_off: '',
				box_y_off: '',
				box_z_off: '',
				box_orient: '',
				tool_postion: '',
				length_wise: '',
				cross_wise: '',
				box_per_pick: '',
				box_orient: '',

				pallet_length: '',
				pallet_width: '',
				pallet_height: '',
				pallet_overhang: '',
				pallet_mini_distance: '',
				sleepsheet_height: ''
			},
			available_layers: [],
			used_layers: [],
			info: {
				name: 'new mission',
				creator: 'COMAU',
				product: 'COMAU',
				company: 'COMAU China'
				code_: ''	  		
			},
	  }
	  initialize: (params) ->
	  	@aLogger = aLogger.create
	  	@aLogger.dev "this is in mission"

	  addLayer: (layer_data) ->
	  	to_updated_available_layers = @get("available_layers")
	  	to_updated_available_layers[to_updated_available_layers.length] = layer_data
	  	@set('available_layers', to_updated_available_layers) 
	  	


	create: new Mission