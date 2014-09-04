(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'logger'], function($, _, Backbone, aLogger) {
    var Mission;
    Mission = (function(_super) {
      var boxes_count;

      __extends(Mission, _super);

      function Mission() {
        this.compositeAUsedLayer = __bind(this.compositeAUsedLayer, this);
        this.compositeALayer = __bind(this.compositeALayer, this);
        this.load_used_layers_info = __bind(this.load_used_layers_info, this);
        this.load_layers_info = __bind(this.load_layers_info, this);
        this.load_setting_info = __bind(this.load_setting_info, this);
        this.load_mission_info = __bind(this.load_mission_info, this);
        this.get_count_of_layers = __bind(this.get_count_of_layers, this);
        this.get_count_of_sheets = __bind(this.get_count_of_sheets, this);
        this.get_total_height = __bind(this.get_total_height, this);
        this.validate_used_layers = __bind(this.validate_used_layers, this);
        this.is_blank = __bind(this.is_blank, this);
        this.is_int = __bind(this.is_int, this);
        this.is_real = __bind(this.is_real, this);
        this.max_number_of_used_layers = __bind(this.max_number_of_used_layers, this);
        this.max_number_of_layers = __bind(this.max_number_of_layers, this);
        return Mission.__super__.constructor.apply(this, arguments);
      }

      boxes_count = 0;

      Mission.prototype.defaults = {
        name: 'new_mission',
        creator: '',
        product: '',
        company: '',
        code: '',
        frame_line_in_index: 1,
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
        box_width: 20,
        box_height: 20,
        box_weight: 10,
        box_per_pick: 1,
        box_x_off: 0,
        box_y_off: 0,
        box_z_off: 0,
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
        tare: 1000,
        max_gross: 800,
        max_height: 800,
        max_pack: 4,
        overhang_len: 10,
        overhang_wid: 10,
        available_layers: {},
        used_layers: [],
        used_layers_created_number: 10000
      };

      Mission.prototype.initialize = function(params) {
        this.logger = aLogger.create;
        this.logger.debug("this is in mission");
        return this.on('all', this.validateAttrValue);
      };

      Mission.prototype.max_number_of_layers = function() {
        return 5;
      };

      Mission.prototype.max_number_of_used_layers = function() {
        return 8;
      };

      Mission.prototype.is_real = function(attr) {
        var rReal, result;
        rReal = /^(\-|\+)?([0-9]+(\.[0-9]+)?)$/;
        result = rReal.test(this.get(attr));
        if (!result) {
          console.log("validateAttrValue: " + attr + "value: " + (this.get(attr)) + " before: " + (this.previous(attr)) + " is_real? " + result);
        }
        return result;
      };

      Mission.prototype.is_int = function(attr) {
        var rInt, result;
        rInt = /^(\-|\+)?([0-9]+)$/;
        result = rInt.test(this.get(attr));
        if (!result) {
          console.log("validateAttrValue: " + attr + "value: " + (this.get(attr)) + " before: " + (this.previous(attr)) + " is_real? " + result);
        }
        return result;
      };

      Mission.prototype.is_blank = function(attr) {
        return this.get(attr) === '';
      };

      Mission.prototype.validate_layers = function(options) {
        var layer_names;
        if (options == null) {
          options = {
            attr: ''
          };
        }
        layer_names = this.getAvailableLayersOrder();
        if (options.attr === 'count') {
          layer_names = this.getAvailableLayersOrder();
          return this.getAvailableLayersOrder().length < this.max_number_of_layers();
        }
        if (options.attr === 'name') {
          return (options.name !== '') && (!_.contains(layer_names, options.name));
        }
        return false;
      };

      Mission.prototype.validate_used_layers = function(options) {
        var number_of_used_layers;
        if (options == null) {
          options = {
            attr: ''
          };
        }
        if (options.attr === 'count') {
          number_of_used_layers = _.reduce(this.used_layers(), (function(sum, layer) {
            if (layer.name === 'SHEET') {
              return sum;
            } else {
              return sum + 1;
            }
          }), 0, this);
          return number_of_used_layers < this.max_number_of_used_layers();
        }
        return false;
      };

      Mission.prototype.validateAttrValue = function(event_name) {
        var attr, rInteger, result, value_frame_line_in_index, value_frame_line_out_index;
        rInteger = /^\+?[1-9][0-9]*$/;
        result = event_name.split(':');
        attr = result[1];
        switch (attr) {
          case void 0:
            break;
          case 'available_layers':
            break;
          case 'used_layers':
          case 'used_layers_created_number':
            break;
          case 'name':
          case 'tool_name':
            if (this.is_blank(attr)) {
              this.set(attr, this.previous(attr));
              return window.appController.flash({
                message: "[" + attr + "] could not be blank!"
              });
            } else {
              return window.appController.set_request({
                name: "mission_data." + attr,
                value: this.get(attr),
                type: 'str'
              });
            }
            break;
          case 'creator':
          case 'product':
          case 'company':
          case 'code':
            return window.appController.set_request({
              name: "mission_data." + attr,
              value: this.get(attr),
              type: 'str'
            });
          case 'tool_position_x':
          case 'tool_position_y':
          case 'tool_position_z':
          case 'tool_position_a':
          case 'tool_position_r':
          case 'tool_position_e':
            if (!this.is_real(attr)) {
              this.set(attr, this.previous(attr));
            } else {
              window.appController.set_request({
                name: "setting_data." + attr,
                value: this.get(attr)
              });
              window.appController.routine_request({
                name: 'setTool'
              });
            }
            break;
          case 'tcp_position_x':
          case 'tcp_position_y':
          case 'tcp_position_z':
          case 'tcp_position_a':
          case 'tcp_position_r':
          case 'tcp_position_e':
            if (!this.is_real(attr)) {
              this.set(attr, this.previous(attr));
            } else {
              window.appController.set_request({
                name: "setting_data." + attr,
                value: this.get(attr)
              });
            }
            break;
          case 'length_wise':
          case 'cross_wise':
          case 'orient':
            window.appController.set_request({
              name: "setting_data." + attr,
              value: this.get(attr).toString()
            });
            break;
          case 'box_length':
          case 'box_width':
            if (!this.is_int(attr) || this.get(attr) < 1) {
              this.set(attr, this.previous(attr));
            } else {
              if (parseInt(this.get('box_length')) < parseInt(this.get('box_width'))) {
                this.logger.debug("" + (this.get('box_length')) + " < " + (this.get('box_width')));
                this.set('box_width', this.previous('box_width'));
                this.set('box_length', this.previous('box_length'));
              } else {
                window.appController.set_request({
                  name: "setting_data." + attr,
                  value: this.get(attr)
                });
              }
            }
            break;
          case 'box_x_off':
          case 'box_y_off':
          case 'box_z_off':
            if (!this.is_int(attr)) {
              return this.set(attr, this.previous(attr));
            } else {
              return window.appController.set_request({
                name: "setting_data." + attr,
                value: this.get(attr)
              });
            }
            break;
          case 'mini_distance':
          case 'sleepsheet_height':
          case 'overhang_len':
          case 'overhang_wid':
            if (!this.is_int(attr) || this.get(attr) < 0) {
              return this.set(attr, this.previous(attr));
            } else {
              return window.appController.set_request({
                name: "setting_data." + attr,
                value: this.get(attr)
              });
            }
            break;
          case 'box_height':
          case 'box_weight':
          case 'box_per_pick':
          case 'pallet_length':
          case 'pallet_width':
          case 'pallet_height':
          case 'tare':
          case 'max_gross':
          case 'max_height':
          case 'max_pack':
            if (!this.is_int(attr) || this.get(attr) < 1) {
              return this.set(attr, this.previous(attr));
            } else {
              return window.appController.set_request({
                name: "setting_data." + attr,
                value: this.get(attr)
              });
            }
            break;
          case 'frame_line_in_index':
            this.logger.dev("[mission.coffee]: frame_line_in_index");
            value_frame_line_in_index = window.appController.mission.get('frame_line_in_index');
            value_frame_line_out_index = window.appController.mission.get('frame_line_out_index');
            if (!this.is_int(attr) || this.get(attr) < 0 || value_frame_line_in_index === value_frame_line_out_index) {
              this.set(attr, this.previous(attr));
            } else {
              window.appController.set_request({
                name: 'setting_data.frame_line_in_index',
                value: this.get('frame_line_in_index')
              });
              window.appController.load_frame_in_data();
            }
            break;
          case 'frame_line_out_index':
            this.logger.dev("[mission.coffee]: frame_line_out_index");
            value_frame_line_in_index = window.appController.mission.get('frame_line_in_index');
            value_frame_line_out_index = window.appController.mission.get('frame_line_out_index');
            if (!this.is_int(attr) || this.get(attr) < 0 || value_frame_line_in_index === value_frame_line_out_index) {
              this.set(attr, this.previous(attr));
            } else {
              window.appController.set_request({
                name: 'setting_data.frame_line_out_index',
                value: window.appController.mission.get('frame_line_out_index')
              });
              window.appController.load_frame_out_data();
            }
            break;
          case 'tool_index':
            if (!this.is_int(attr) || this.get(attr) < 0 || this.get(attr) > 30) {
              return this.set(attr, this.previous(attr));
            } else {
              this.logger.dev("[mission.coffee]: tool_index");
              window.appController.set_request({
                name: 'setting_data.tool_index',
                value: this.get('tool_index')
              });
              return window.appController.load_tool_data();
            }
            break;
          default:
            if (!this.is_int(attr)) {
              return this.set(attr, this.previous(attr));
            } else {
              return window.appController.set_request({
                name: "setting_data." + attr,
                value: this.get(attr)
              });
            }
        }
      };

      Mission.prototype.generate_valid_layer_name = function(new_layer_name) {
        while (!this.validate_layers({
            attr: 'name',
            name: new_layer_name
          })) {
          new_layer_name = "Layer_" + ((Math.random() * 10e16).toString().substr(0, 5));
        }
        return new_layer_name;
      };

      Mission.prototype.addLayer = function(layer_data) {
        var to_updated_available_layers;
        to_updated_available_layers = this.get("available_layers");
        to_updated_available_layers[layer_data.id] = layer_data;
        return this.set('available_layers', to_updated_available_layers);
      };

      Mission.prototype.removeLayer = function(layer_id) {
        var result, to_deleted_layer_name, to_updated_available_layers, to_updated_used_layers;
        to_updated_available_layers = this.get("available_layers");
        to_deleted_layer_name = to_updated_available_layers[layer_id].name;
        delete to_updated_available_layers[layer_id];
        this.set('available_layers', to_updated_available_layers);
        to_updated_used_layers = this.get("used_layers");
        result = _.reject(to_updated_used_layers, function(used_layer) {
          return String(used_layer.name) === String(to_deleted_layer_name);
        });
        return this.set('used_layers', result);
      };

      Mission.prototype.layers = function() {
        return this.get("available_layers");
      };

      Mission.prototype.getAvailableLayersOrder = function() {
        var result;
        result = _.map(_.values(this.get("available_layers")), function(layer) {
          return layer.name;
        });
        return result = _.filter(result, function(layer_name) {
          return layer_name !== 'SHEET';
        });
      };

      Mission.prototype.used_layers = function() {
        return this.get("used_layers");
      };

      Mission.prototype.addToUsedLayers = function(layer_name, layer_option_value, layer_ulid) {
        var current_number, new_used_layer, to_updated_used_layers;
        to_updated_used_layers = this.get("used_layers");
        current_number = this.get('used_layers_created_number');
        new_used_layer = {
          name: layer_name,
          option_value: layer_option_value,
          id: "" + layer_name + "-----" + current_number + "-----" + (Math.random() * 10e16),
          ulid: layer_ulid
        };
        this.set('used_layers_created_number', current_number + 1);
        to_updated_used_layers.push(new_used_layer);
        return this.set('used_layers', to_updated_used_layers);
      };

      Mission.prototype.removeFromUsedLayers = function(layer_option_value) {
        var result, to_updated_used_layers;
        to_updated_used_layers = this.get("used_layers");
        result = _.reject(to_updated_used_layers, function(used_layer) {
          return String(used_layer.option_value) === String(layer_option_value);
        });
        this.logger.debug("used_layer_length: " + result.length);
        return this.set('used_layers', result);
      };

      Mission.prototype.getUsedLayersOrder = function() {
        return this.get('used_layers');
      };

      Mission.prototype.getUsedLayersName = function() {
        return _.map(this.used_layers(), function(a_used_layer) {
          return a_used_layer.name;
        });
      };

      Mission.prototype.getLayerDataByName = function(layer_name) {
        var all_layers;
        all_layers = _.values(this.layers());
        return _.find(all_layers, function(a_layer) {
          return a_layer.name === layer_name;
        });
      };

      Mission.prototype.updateUsedLayersNameByUlid = function(new_layer_name, layer_ulid) {
        var result, to_updated_used_layers;
        to_updated_used_layers = this.get("used_layers");
        result = _.map(to_updated_used_layers, function(used_layer) {
          if (layer_ulid === used_layer.ulid) {
            used_layer.name = new_layer_name;
            return used_layer;
          } else {
            return used_layer;
          }
        });
        return this.set('used_layers', result);
      };

      Mission.prototype.getBoxesNumberByLayerName = function(layer_name) {
        var boxes_number;
        boxes_number = this.getLayerDataByName(layer_name).boxes.length;
        if (boxes_number !== void 0) {
          return boxes_number;
        } else {
          return 0;
        }
      };

      Mission.prototype.get_total_height = function() {
        var all_layers_name;
        all_layers_name = this.getUsedLayersName();
        return _.reduce(all_layers_name, (function(sum, layer_name) {
          var layer_height;
          if (this.getBoxesNumberByLayerName(layer_name) > 0) {
            layer_height = Number.parseInt(this.get('box_height'));
          } else if (layer_name === 'SHEET') {
            layer_height = Number.parseInt(this.get('sleepsheet_height'));
          } else {
            layer_height = 0;
          }
          return sum + layer_height;
        }), 0, this);
      };

      Mission.prototype.get_total_box = function() {
        var all_layers_name;
        all_layers_name = this.getUsedLayersName();
        return _.reduce(all_layers_name, (function(sum, layer_name) {
          return sum + this.getBoxesNumberByLayerName(layer_name);
        }), 0, this);
      };

      Mission.prototype.get_total_weight = function() {
        var all_layers, box_weight;
        all_layers = this.getUsedLayersName();
        box_weight = this.get('box_weight');
        return _.reduce(all_layers, (function(sum, layer_name) {
          return sum + box_weight * this.getBoxesNumberByLayerName(layer_name);
        }), 0, this);
      };

      Mission.prototype.get_total_block_dim = function() {
        var all_layers;
        all_layers = this.getUsedLayersName();
        return _.reduce(all_layers, (function(sum, layer_name) {
          return sum + this.getBoxesNumberByLayerName(layer_name);
        }), 0, this);
      };

      Mission.prototype.get_count_of_sheets = function() {
        return _.reduce(this.used_layers(), (function(sum, layer) {
          if (layer.name === 'SHEET') {
            return sum + 1;
          } else {
            return sum;
          }
        }), 0, this);
      };

      Mission.prototype.get_count_of_layers = function() {
        return this.getAvailableLayersOrder().length;
      };

      Mission.prototype.load_mission_info = function(mission_data_from_pdl) {
        this.set('name', mission_data_from_pdl.name);
        this.set('creator', mission_data_from_pdl.creator);
        this.set('product', mission_data_from_pdl.product);
        this.set('company', mission_data_from_pdl.company);
        return this.set('code', mission_data_from_pdl.code);
      };

      Mission.prototype.load_setting_info = function(setting_data_from_pdl) {
        this.set('frame_line_in_index', setting_data_from_pdl.frame_line_in_index);
        this.set('frame_line_in_position_x', setting_data_from_pdl.frame_line_in_position_x);
        this.set('frame_line_in_position_y', setting_data_from_pdl.frame_line_in_position_y);
        this.set('frame_line_in_position_z', setting_data_from_pdl.frame_line_in_position_z);
        this.set('frame_line_in_position_r', setting_data_from_pdl.frame_line_in_position_r);
        this.set('frame_line_out_index', setting_data_from_pdl.frame_line_out_index);
        this.set('frame_line_out_position_x', setting_data_from_pdl.frame_line_out_position_x);
        this.set('frame_line_out_position_y', setting_data_from_pdl.frame_line_out_position_y);
        this.set('frame_line_out_position_z', setting_data_from_pdl.frame_line_out_position_z);
        this.set('frame_line_out_position_r', setting_data_from_pdl.frame_line_out_position_r);
        this.set('box_length', setting_data_from_pdl.box_length);
        this.set('box_width', setting_data_from_pdl.box_width);
        this.set('box_height', setting_data_from_pdl.box_height);
        this.set('box_weight', setting_data_from_pdl.box_weight);
        this.set('box_per_pick', setting_data_from_pdl.box_per_pick);
        this.set('box_x_off', setting_data_from_pdl.box_x_off);
        this.set('box_y_off', setting_data_from_pdl.box_y_off);
        this.set('box_z_off', setting_data_from_pdl.box_z_off);
        this.set('orient', setting_data_from_pdl.orient);
        this.set('tool_index', setting_data_from_pdl.tool_index);
        this.set('tool_name', setting_data_from_pdl.tool_name);
        this.set('tool_position_x', setting_data_from_pdl.tool_position_x);
        this.set('tool_position_y', setting_data_from_pdl.tool_position_y);
        this.set('tool_position_z', setting_data_from_pdl.tool_position_z);
        this.set('tool_position_a', setting_data_from_pdl.tool_position_a);
        this.set('tool_position_e', setting_data_from_pdl.tool_position_e);
        this.set('tool_position_r', setting_data_from_pdl.tool_position_r);
        this.set('tcp_position_x', setting_data_from_pdl.tcp_position_x);
        this.set('tcp_position_y', setting_data_from_pdl.tcp_position_y);
        this.set('tcp_position_z', setting_data_from_pdl.tcp_position_z);
        this.set('tcp_position_a', setting_data_from_pdl.tcp_position_a);
        this.set('tcp_position_e', setting_data_from_pdl.tcp_position_e);
        this.set('tcp_position_r', setting_data_from_pdl.tcp_position_r);
        this.set('length_wise', setting_data_from_pdl.length_wise);
        this.set('cross_wise', setting_data_from_pdl.cross_wise);
        this.set('pallet_length', setting_data_from_pdl.pallet_length);
        this.set('pallet_width', setting_data_from_pdl.pallet_width);
        this.set('pallet_height', setting_data_from_pdl.pallet_height);
        this.set('pallet_weight', setting_data_from_pdl.pallet_weight);
        this.set('sleepsheet_height', setting_data_from_pdl.sleepsheet_height);
        this.set('tare', setting_data_from_pdl.tare);
        this.set('max_gross', setting_data_from_pdl.max_gross);
        this.set('max_height', setting_data_from_pdl.max_height);
        this.set('mini_distance', setting_data_from_pdl.mini_distance);
        this.set('overhang_len', setting_data_from_pdl.overhang_len);
        this.set('overhang_wid', setting_data_from_pdl.overhang_wid);
        return this.set('max_pack', setting_data_from_pdl.max_pack);
      };

      Mission.prototype.load_layers_info = function(layers_from_pdl) {
        var a_layer, a_layer_name, available_layers, available_layers_names, boxes, i, new_layer, used_layers, _i, _j, _k, _len, _len1, _ref, _results;
        this.set('available_layers', {});
        boxes = {};
        available_layers_names = _.select(layers_from_pdl.layers, ((function(_this) {
          return function(a_layer) {
            return a_layer.is_available === true;
          };
        })(this)), this);
        available_layers_names = _.map(available_layers_names, ((function(_this) {
          return function(a_layer) {
            return a_layer.name;
          };
        })(this)), this);
        for (_i = 0, _len = available_layers_names.length; _i < _len; _i++) {
          a_layer = available_layers_names[_i];
          boxes[a_layer] = [];
        }
        window.appController.routine_request({
          name: 'countOfBoxes',
          params: ['']
        });
        window.appController.get_request({
          name: 'temp_boxes_count',
          callback: (function(_this) {
            return function(data) {
              return _this.boxes_count = Number.parseInt(data);
            };
          })(this)
        });
        for (i = _j = 1, _ref = this.boxes_count; _j <= _ref; i = _j += 1) {
          window.appController.routine_request({
            name: 'findBox',
            params: [i, '']
          });
          window.appController.get_request({
            name: 'request_box',
            callback: function(data) {
              var box;
              box = JSON.parse(data);
              if (box.is_available && boxes[box.layer_name] !== void 0) {
                return boxes[box.layer_name].push(box);
              }
            }
          });
        }
        _results = [];
        for (_k = 0, _len1 = available_layers_names.length; _k < _len1; _k++) {
          a_layer_name = available_layers_names[_k];
          available_layers = this.get('available_layers');
          new_layer = this.compositeALayer(a_layer_name, boxes[a_layer_name]);
          available_layers[new_layer.id] = new_layer;
          this.set('available_layers', available_layers);
          _results.push(used_layers = this.get('used_layers'));
        }
        return _results;
      };

      Mission.prototype.load_used_layers_info = function(used_layers_from_pdl) {
        var a_layer_name, new_used_layer, used_layers, used_layers_name, _i, _len;
        this.set('used_layers', []);
        used_layers_name = _.select(used_layers_from_pdl.used_layers, ((function(_this) {
          return function(a_layer) {
            return a_layer.is_available === true;
          };
        })(this)), this);
        used_layers_name = _.map(used_layers_name, ((function(_this) {
          return function(a_layer) {
            return a_layer.name;
          };
        })(this)), this);
        used_layers = [];
        for (_i = 0, _len = used_layers_name.length; _i < _len; _i++) {
          a_layer_name = used_layers_name[_i];
          new_used_layer = this.compositeAUsedLayer(a_layer_name);
          used_layers.push(new_used_layer);
        }
        return this.set('used_layers', used_layers);
      };

      Mission.prototype.compositeALayer = function(layer_name, layer_boxes) {
        var new_layer;
        return new_layer = {
          name: layer_name,
          boxes: layer_boxes,
          id: "layer-item-" + layer_name + "-" + (Math.random() * 10e16),
          ulid: "" + layer_name + "------ulid" + (Math.random() * 10e17)
        };
      };

      Mission.prototype.compositeAUsedLayer = function(layer_name) {
        var new_used_layer;
        return new_used_layer = {
          id: "" + layer_name + "-----" + (this.get('used_layers').length) + "-----" + (Math.random() * 10e16),
          name: layer_name,
          option_value: "" + layer_name + "-----option" + (Math.random() * 10e16),
          ulid: window.appController.getUlidByName(layer_name)
        };
      };

      Mission.prototype.generateCSVData = function() {
        var a_box, a_layer, a_layer_name, all_layers, boxes_in_a_layer, gripperAfterStatus, gripperStatus, index_, insert_angle, layerNO, packageSequence, packageSequenceInLayer, packages, _i, _len, _results;
        window.appController.routine_request({
          name: 'resetCSVFile',
          params: ["" + (this.get('name')) + ".csv"]
        });
        this.pprint("_versionOfMultipck;" + (this.get('name')) + ";" + (this.get('creator')) + ";" + (this.get('company')));
        this.pprint("\"pallet\";_description;" + (this.get('pallet_length')) + ";" + (this.get('pallet_width')) + ";" + (this.get('pallet_height')) + ";" + (this.get('tare')));
        this.pprint("\"sheet\";" + (this.get('sleepsheet_height')) + ";" + (this.get_count_of_sheets()));
        this.pprint("\"pall_info\";" + (this.get_total_box()) + ";" + (this.get_count_of_layers()) + ";" + (this.get_total_weight()) + ";" + (this.get('pallet_length')) + ";" + (this.get('pallet_width')) + ";" + (this.get('pallet_height')));
        this.pprint("\"tool\";" + (this.get('tool_name')) + ";0;0;0;" + (this.get('tool_position_x')) + ";" + (this.get('tool_position_y')) + ";" + (this.get('tool_position_z')) + ";0;0;0;0");
        this.pprint("\"linein\";Conveyor;" + (this.get('frame_line_in_index')) + ";0;");
        this.pprint("\"lineout\";Pallet place definition;" + (this.get('frame_line_out_index')) + ";0;");
        this.pprint("\"pack\";" + (this.get('product')) + ";" + (this.get('box_length')) + ";" + (this.get('box_width')) + ";" + (this.get('box_height')) + ";" + (this.get('box_weight')) + ";0;0;0");
        this.pprint("010000");
        this.pprint("120000");
        this.pprint("220000");
        all_layers = this.getUsedLayersName();
        packageSequence = 1;
        layerNO = 1;
        packages = new Array(this.get('box_per_pick'));
        index_ = 0;
        while (index_ < packages.length) {
          packages[index_] = 1;
          index_ += 1;
        }
        gripperStatus = packages.join(' ');
        gripperAfterStatus = _.map(packages, function(el) {
          return 0;
        }).join(' ');
        gripperStatus = _.map(new Array(this.get('box_per_pick')), function(el) {
          return 1;
        }).join(' ');
        gripperAfterStatus = _.map(new Array(this.get('box_per_pick')), function(el) {
          return 0;
        }).join(' ');
        _results = [];
        for (_i = 0, _len = all_layers.length; _i < _len; _i++) {
          a_layer_name = all_layers[_i];
          packageSequenceInLayer = 1;
          a_layer = this.getLayerDataByName(a_layer_name);
          boxes_in_a_layer = a_layer.boxes;
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = boxes_in_a_layer.length; _j < _len1; _j++) {
              a_box = boxes_in_a_layer[_j];
              if (a_box.arrowEnabled) {
                switch (a_box.arrow) {
                  case 0:
                    insert_angle = '0 1';
                    break;
                  case 45:
                    insert_angle = '1 1';
                    break;
                  case 90:
                    insert_angle = '1 0';
                    break;
                  case 135:
                    insert_angle = '1 -1';
                    break;
                  case 180:
                    insert_angle = '0 -1';
                    break;
                  case 225:
                    insert_angle = '-1 -1';
                    break;
                  case 270:
                    insert_angle = '-1 0';
                    break;
                  case 315:
                    insert_angle = '-1 1';
                    break;
                  case 360:
                    insert_angle = '0 1';
                }
              } else {
                insert_angle = '0 0';
              }
              this.pprint("100101;" + (this.get('box_per_pick')) + ";" + (this.get('tcp_position_x')) + ";" + (this.get('tcp_position_y')) + ";" + (this.get('tcp_position_z')) + ";" + (this.get('tcp_position_r')) + ";" + gripperStatus + ";" + packageSequence + ";0;0;0");
              this.pprint("200101;" + a_box.x + ";" + a_box.y + ";" + (this.get('box_height') * layerNO) + ";__tcpRZ;" + insert_angle + ";" + gripperStatus + ";" + gripperAfterStatus + ";0;" + packageSequence + ";" + layerNO + ";" + packageSequenceInLayer + ";1;0;0;0");
              packageSequence += 1;
              _results1.push(packageSequenceInLayer += 1);
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Mission.prototype.pprint = function(str) {
        return window.appController.routine_request({
          name: 'writeCSVFile',
          params: ["" + (this.get('name')) + ".csv", "" + str]
        });
      };

      return Mission;

    })(Backbone.Model);
    return {
      create: new Mission
    };
  });

}).call(this);

/*
//@ sourceMappingURL=mission.js.map
*/
