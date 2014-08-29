(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["logger", "tinybox", 'jquery', 'backbone', 'mission', 'rivets'], function(Logger, Tinybox, $, Backbone, Mission, rivets) {
    var AppController;
    AppController = (function() {
      function AppController() {
        this.sendUsedLayersToSave = __bind(this.sendUsedLayersToSave, this);
        this.sendLayersToSave = __bind(this.sendLayersToSave, this);
        this.after_action = __bind(this.after_action, this);
        this.load_used_layers_data = __bind(this.load_used_layers_data, this);
        this.load_layers_data = __bind(this.load_layers_data, this);
        this.load_settingData_data = __bind(this.load_settingData_data, this);
        this.load_missionData_data = __bind(this.load_missionData_data, this);
        this.load_frame_out_data = __bind(this.load_frame_out_data, this);
        this.load_frame_in_data = __bind(this.load_frame_in_data, this);
        this.load_tool_data = __bind(this.load_tool_data, this);
        this.load_whole_mission_data = __bind(this.load_whole_mission_data, this);
        this.get_selected_layer_name = __bind(this.get_selected_layer_name, this);
        this.set_selected_layer_name = __bind(this.set_selected_layer_name, this);
        this.routine_request = __bind(this.routine_request, this);
        this.get_mission_list = __bind(this.get_mission_list, this);
        this.get_request = __bind(this.get_request, this);
        this.set_request = __bind(this.set_request, this);
        this.logger = Logger.create;
        this.mission = Mission.create;
        this.new_mission = Mission.create;
        this.previous_action = void 0;
        this.current_action = void 0;
        this.selected_layer = void 0;
        this.removed_layer_index = -1;
        this.remote_url = 'http://192.168.1.101:4242/';
        this.program_name = 'pd_db2';
        this.mission_saved_flag = true;
        this.pattern_saved_flag = true;
        this.mission_list = [];
      }

      AppController.prototype.sleep = function(d) {
        var t, _results;
        if (d == null) {
          d = 100;
        }
        t = Date.now();
        _results = [];
        while (Date.now() - t <= d) {
          _results.push(d);
        }
        return _results;
      };

      AppController.prototype.set_request = function(options) {
        var get_url;
        if (options.type === 'str') {
          options.value = "'" + options.value + "'";
        }
        get_url = "set?var=" + options.name + "&prog=" + this.program_name + "&value=" + options.value;
        console.log("" + this.remote_url + get_url);
        return $.ajax({
          url: get_url,
          cache: false,
          async: false,
          success: function(data) {
            if (options.callback !== void 0) {
              return options.callback(data);
            }
          },
          error: function() {
            return window.appController.logger.dev("[set]: error");
          }
        });
      };

      AppController.prototype.get_request = function(options) {
        var get_url;
        get_url = "get?var=" + options.name + "&prog=" + this.program_name;
        console.log("" + this.remote_url + get_url);
        return $.ajax({
          url: get_url,
          cache: false,
          async: false,
          success: function(data) {
            if (options.callback !== void 0) {
              return options.callback(data);
            }
          },
          error: function() {
            return window.appController.logger.dev("[get]: error");
          }
        });
      };

      AppController.prototype.get_mission_list = function() {
        var get_url;
        get_url = "get?dirList=UD:/usr/dev/";
        console.log("" + this.remote_url + get_url);
        return $.ajax({
          url: get_url,
          cache: false,
          async: false,
          success: function(data) {
            return window.appController.mission_list = JSON.parse(data);
          },
          error: function() {
            return window.appController.logger.dev("[get_mission_list]: error");
          }
        });
      };

      AppController.prototype.routine_request = function(options) {
        var get_url, params, params_, result;
        params = options.params;
        if (params !== void 0) {
          params_ = _.map(params, function(param) {
            if (typeof param === 'string') {
              return "'" + param + "'";
            } else {
              return param;
            }
          });
          result = "(" + (params_.join(',')) + ")";
        } else {
          result = '';
        }
        get_url = "run?routine=" + options.name + result + "&prog=" + this.program_name;
        console.log("" + this.remote_url + get_url);
        return $.ajax({
          url: get_url,
          cache: false,
          async: false,
          success: function(data) {
            if (options.callback !== void 0) {
              return options.callback(data);
            }
          },
          error: function() {
            return window.appController.logger.dev("[get]: error");
          }
        });
      };

      AppController.prototype.set_selected_layer_name = function(selected_layer_name) {
        return window.appController.set_request({
          name: 'edting_layer_name',
          value: selected_layer_name,
          type: 'str'
        });
      };

      AppController.prototype.get_selected_layer_name = function() {
        var selected_layer_name;
        selected_layer_name = '';
        window.appController.get_request({
          name: 'edting_layer_name',
          callback: function(data) {
            return selected_layer_name = data;
          }
        });
        return selected_layer_name;
      };

      AppController.prototype.load_whole_mission_data = function(mission_data_name) {
        this.mission.set('available_layers', {});
        this.mission.set('used_layers', []);
        this.routine_request({
          name: 'loadVarFile',
          params: [mission_data_name]
        });
        this.load_tool_data();
        this.load_frame_in_data();
        this.load_frame_out_data();
        this.load_missionData_data();
        return this.load_settingData_data();
      };

      AppController.prototype.load_tool_data = function() {
        this.routine_request({
          name: 'getTool'
        });
        return this.get_request({
          name: 'setting_data',
          callback: function(data) {
            return window.appController.mission.load_setting_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.load_frame_in_data = function() {
        this.routine_request({
          name: 'getFrameIn'
        });
        return this.get_request({
          name: 'setting_data',
          callback: function(data) {
            return window.appController.mission.load_setting_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.load_frame_out_data = function() {
        this.routine_request({
          name: 'getFrameOut'
        });
        return this.get_request({
          name: 'setting_data',
          callback: function(data) {
            return window.appController.mission.load_setting_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.load_missionData_data = function() {
        return this.get_request({
          name: 'mission_data',
          callback: function(data) {
            return window.appController.mission.load_mission_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.load_settingData_data = function() {
        return this.get_request({
          name: 'setting_data',
          callback: function(data) {
            return window.appController.mission.load_setting_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.load_layers_data = function() {
        return this.get_request({
          name: 'layers',
          callback: function(data) {
            return window.appController.mission.load_layers_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.load_used_layers_data = function() {
        return this.get_request({
          name: 'used_layers',
          callback: function(data) {
            return window.appController.mission.load_used_layers_info(JSON.parse(data));
          }
        });
      };

      AppController.prototype.flash = function(options) {
        if (options == null) {
          options = {
            closable: true
          };
        }
        $('#popup').html(options.message);
        return $("#popup").modal({
          escapeClose: options.closable,
          clickClose: options.closable,
          showClose: options.closable
        });
      };

      AppController.prototype.before_action = function(route, params) {
        var action, new_message;
        action = params[0];
        this.previous_action = this.current_action;
        this.current_action = {
          route: route,
          action: params[0]
        };
        if (this.previous_action !== void 0) {
          this.logger.debug("[before_action]: @previous_action " + this.previous_action.route + " " + this.previous_action.action);
        }
        if (this.previous_action !== void 0) {
          this.logger.debug("[before_action]: @current_action " + this.current_action.route + " " + this.current_action.action);
        }
        rivets.adapters[":"] = {
          subscribe: function(obj, keypath, callback) {
            obj.on("change:" + keypath, callback);
          },
          unsubscribe: function(obj, keypath, callback) {
            obj.off("change:" + keypath, callback);
          },
          read: function(obj, keypath) {
            return obj.get(keypath);
          },
          publish: function(obj, keypath, value) {
            return obj.set(keypath, value);
          }
        };
        this.get_mission_list();
        if (route === 'mission/*action') {
          if (action === 'new') {
            if (window.appController.mission_saved_flag === true) {
              this.mission = this.new_mission;
            } else {
              this.flash({
                message: 'Do you want to abandon the modification?'
              });
              window.router.navigate("#program", {
                trigger: true
              });
              return false;
            }
          }
          if (action === 'save') {
            this.flash({
              message: 'Saving Data......',
              closable: false
            });
          }
          if (action === 'save_as') {
            new_message = '<form class="navbar-form"> <div class="form-group"> <input type="text" class="form-control" id="to-renamed-mission" placeholder="' + ("" + selected_mission_name) + '"> </div> <a class="btn btn-default" id="misson_rename">Rename</a> </form>';
            this.flash({
              message: 'Saving Data......',
              closable: false
            });
          }
        }
        if (route === 'pattern/*action') {
          if (action === 'new' || action === 'clone') {
            if (!this.mission.validate_layers({
              attr: 'count'
            })) {
              window.router.navigate("#patterns", {
                trigger: true
              });
              this.flash({
                message: 'Reach the maximam number of Pattern!',
                closable: true
              });
              return false;
            }
          }
        }
      };

      AppController.prototype.after_action = function(route, params) {
        var a_layer, action, clone_layer_name, cross_wise_value, layers, length_wise_value, new_message, orient_value, selected_layer, selected_layer_name, selected_mission_name, to_reload_mission_name, _i, _len;
        action = params[0];
        rivets.bind($('.mission_'), {
          mission: this.mission
        });
        this.load_whole_mission_data();
        if (route === 'placeSetting') {
          orient_value = window.appController.mission.get('orient');
          $("[name='orient']").bootstrapSwitch('state', orient_value);
          $("[name='orient']").on("switchChange.bootstrapSwitch", function(event, state) {
            return window.appController.mission.set('orient', state);
          });
        }
        if (route === 'additionalInfo') {
          length_wise_value = window.appController.mission.get('length_wise');
          $("[name='length']").bootstrapSwitch('state', length_wise_value);
          $("[name='length']").on("switchChange.bootstrapSwitch", function(event, state) {
            window.appController.mission.set('length_wise', state);
            return $("[name='cross']").bootstrapSwitch('state', !state);
          });
          cross_wise_value = window.appController.mission.get('cross_wise');
          $("[name='cross']").bootstrapSwitch('state', cross_wise_value);
          $("[name='cross']").on("switchChange.bootstrapSwitch", function(event, state) {
            window.appController.mission.set('cross_wise', state);
            return $("[name='length']").bootstrapSwitch('state', !state);
          });
        }
        if (route === 'patterns') {
          this.load_layers_data();
          this.load_used_layers_data();
          layers = _.values(this.mission.get('available_layers'));
          for (_i = 0, _len = layers.length; _i < _len; _i++) {
            a_layer = layers[_i];
            if (a_layer.name !== 'SHEET') {
              $('#patterns').append("<li class=\"list-group-item\" id=\"" + a_layer.id + "\">" + a_layer.name + "</li>");
            }
          }
          $("[id^='layer-item-']").on('click', function(el) {
            var selected_layer_name;
            $("[id^='layer-item-']").removeClass('selected-item');
            $(this).addClass('selected-item');
            selected_layer_name = $('.list-group-item.selected-item').html();
            window.appController.set_selected_layer_name(selected_layer_name);
          });
        }
        if (route === 'mission/*action') {
          if (action === 'delete') {
            this.get_mission_list();
            selected_mission_name = $('.list-group-item.selected-item').html();
            if (_.contains(this.mission_list, "" + selected_mission_name + ".var")) {
              this.routine_request({
                name: 'deleteVarFile',
                params: [selected_mission_name]
              });
            } else {
              this.flash("" + selected_mission_name + " does not exist!", {
                close: true
              });
            }
            window.router.navigate("#mission/index", {
              trigger: true
            });
            return false;
          }
          if (action === 'rename') {
            selected_mission_name = $('.list-group-item.selected-item').html();
            if (selected_mission_name === void 0) {
              window.router.navigate("#mission/index", {
                trigger: true
              });
              return false;
            }
            new_message = '<form class="navbar-form"> <div class="form-group"> <input type="text" class="form-control" id="to-renamed-mission" placeholder="' + ("" + selected_mission_name) + '"> </div> <a class="btn btn-default" id="misson_rename">Rename</a> </form>';
            this.flash({
              message: new_message,
              closable: false
            });
            $('#misson_rename').click(function() {
              if ($('#to-renamed-mission').val() !== '') {
                console.log("todo -> rename mission in pdl");
              }
              return $.modal.close();
            });
            window.router.navigate("#mission/index", {
              trigger: true
            });
            return false;
          }
          if (action === 'index') {
            $('a[href="#mission/load"]').click(function() {
              return window.appController.flash({
                message: 'Loading Data...',
                closable: false
              });
            });
            this.get_mission_list();
            if (this.mission_list.length > 0) {
              _.each(window.appController.mission_list, function(a_mission) {
                var r_var_file;
                r_var_file = /\w+\.var$/;
                if (r_var_file.test(a_mission)) {
                  return $('#mission_list').append("<li class=\"list-group-item mission_item\" >" + (a_mission.substring(0, a_mission.length - 4)) + "</li>");
                }
              });
              $(".mission_item").on('click', function(el) {
                $(".mission_item").removeClass('selected-item');
                return $(this).addClass('selected-item');
              });
            }
          }
          if (action === 'save') {
            this.routine_request({
              name: 'saveVarFile',
              params: [this.mission.get('name')]
            });
            this.mission.generateCSVData();
            this.get_mission_list();
            $.modal.close();
            window.router.navigate("#program", {
              trigger: true
            });
          }
          if (action === 'edit') {
            this.load_layers_data();
            this.load_used_layers_data();
            $('.ms-list').empty();
            $('#my-select').empty();
            _.each(this.mission.get('available_layers'), (function(a_layer, layer_index) {
              return $('#my-select').append("<option value='" + a_layer.name + "-----" + (Math.random() * 10e16) + "'>" + a_layer.name + "</option>");
            }), this);
            $('#my-select').prepend("<option value='PALLET' selected>0: PALLET</option>");
            _.each(window.appController.getUsedLayersOrder(), (function(a_layer, layer_index) {
              return $('#my-select').prepend("<option value=" + a_layer.option_value + " layer-index='" + layer_index + "' selected>" + (layer_index + 1) + ": " + a_layer.name + "</option>");
            }), this);
            $('#my-select').multiSelect({
              afterSelect: (function(_this) {
                return function(option_value) {
                  var regex, selected_layer_info, selected_layer_name, selected_layer_ulid;
                  _this.logger.debug("afterSelect: " + option_value);
                  regex = /\s*-----\s*/;
                  selected_layer_info = option_value[0].split(regex);
                  selected_layer_name = selected_layer_info[0];
                  selected_layer_ulid = _this.getUlidByName(selected_layer_name);
                  if (window.appController.mission.validate_used_layers({
                    attr: 'count'
                  })) {
                    window.appController.addToUsedLayers(selected_layer_name, option_value[0], selected_layer_ulid);
                  } else {
                    window.appController.flash({
                      message: "Reach maximam number of used layers"
                    });
                  }
                  _this.refreshSelectableAndSelectedLayers();
                  window.appController.mission_saved_flag = false;
                  _this.routine_request({
                    name: 'resetUsedLayers'
                  });
                  _this.sendUsedLayersToSave();
                  return rivets.bind($('.mission_'), {
                    mission: window.appController.mission
                  });
                };
              })(this),
              afterDeselect: (function(_this) {
                return function(option_value) {
                  var regex, value, value_name;
                  _this.logger.debug("afterDeselect: " + option_value);
                  regex = /\s*-----\s*/;
                  value = option_value[0].split(regex);
                  value_name = value[0];
                  window.appController.removeFromUsedLayers(option_value);
                  _this.refreshSelectableAndSelectedLayers();
                  window.appController.mission_saved_flag = false;
                  _this.routine_request({
                    name: 'resetUsedLayers'
                  });
                  _this.sendUsedLayersToSave();
                  return rivets.bind($('.mission_'), {
                    mission: window.appController.mission
                  });
                };
              })(this)
            });
            $("input").attr('readonly', true);
          }
          if (action === 'load') {
            selected_mission_name = $('.list-group-item.selected-item').html();
            if (selected_mission_name !== void 0) {
              this.mission.set('name', selected_mission_name);
              console.log("selected_mission_name: " + selected_mission_name);
              console.log("@mission.get('name'): " + (this.mission.get('name')));
              console.log("----->before: load_whole_mission_data");
              this.load_whole_mission_data(selected_mission_name);
              console.log("----->after: load_whole_mission_data");
              $.modal.close();
              window.router.navigate("#program", {
                trigger: true
              });
              rivets.bind($('.mission_'), {
                mission: this.mission
              });
              return false;
            }
            $.modal.close();
            window.router.navigate("#mission/index", {
              trigger: true
            });
            return false;
          }
          if (action === 'reload') {
            this.get_mission_list();
            to_reload_mission_name = "" + (this.mission.get('name')) + ".var";
            if (_.contains(this.mission_list, to_reload_mission_name)) {
              this.routine_request({
                name: 'loadVarFile',
                params: [to_reload_mission_name]
              });
              console.log("----->before: reload_whole_mission_data");
              this.load_whole_mission_data(selected_mission_name);
              console.log("----->after: reload_whole_mission_data");
            } else {
              this.flash({
                message: "[" + (this.mission.get('name')) + "] does not exist in ROBOT!",
                close: true
              });
            }
            window.router.navigate("#program", {
              trigger: true
            });
            return false;
          }
        }
        if (route === 'pattern/*action') {
          this.load_layers_data();
          if (action === 'new') {
            window.appController.set_selected_layer_name('');
            $('#layer-name').val("Layer_" + ((Math.random() * 10e16).toString().substr(0, 5)));
            $('#layer-name').focus().select();
            $("#layer-name").focusin(function() {}).focusout(function() {
              var new_layer_name;
              if ($('#layer-name').val() === '') {
                window.appController.flash({
                  message: 'layer name can not be empty!'
                });
                new_layer_name = "Layer_" + ((Math.random() * 10e16).toString().substr(0, 5));
              } else {
                new_layer_name = $('#layer-name').val();
              }
              new_layer_name = window.appController.mission.generate_valid_layer_name(new_layer_name);
              $('#layer-name').val(new_layer_name);
              return $('#layer-name').focus();
            });
          }
          if (action === 'edit') {
            selected_layer_name = window.appController.get_selected_layer_name();
            selected_layer = window.appController.mission.getLayerDataByName(selected_layer_name);
            this.load_pattern_data(selected_layer_name);
            $('#layer-name').val(selected_layer_name);
            $('#layer-name').focus().select();
          }
          if (action === 'clone') {
            selected_layer_name = window.appController.get_selected_layer_name();
            selected_layer = window.appController.mission.getLayerDataByName(selected_layer_name);
            if (selected_layer !== void 0) {
              clone_layer_name = "" + selected_layer.name + "_clone";
              window.appController.saveLayerBy({
                name: clone_layer_name,
                boxes: selected_layer.boxes
              });
            }
            window.router.navigate("patterns", {
              trigger: true
            });
            return false;
          }
        }
        rivets.bind($('.mission_'), {
          mission: this.mission
        });
        if (route === 'pickSetting') {
          $("input").attr("readonly", true);
          $("input#table-index").attr("readonly", false);
          $("[name='teach']").on("switchChange.bootstrapSwitch", function(event, state) {
            if (state) {
              $('a.teach').removeClass('label-primary');
              $('a.teach').addClass('label-success');
              $('a.teach').html('');
              $("input").attr("readonly", true);
              return $("input#table-index").attr("readonly", false);
            } else {
              $('a.teach').removeClass('label-success');
              $('a.teach').addClass('label-success');
              $('a.teach').html('Place');
              $("a.teach").attr("href", "#tool/set");
              return $("input").attr("readonly", false);
            }
          });
          this.load_tool_data();
          rivets.bind($('.mission_'), {
            mission: this.mission
          });
        }
        if (route === 'tool/*action') {
          if (action === 'set') {
            this.routine_request({
              name: 'setTool'
            });
            window.router.navigate("#pickSetting", {
              trigger: true
            });
            rivets.bind($('.mission_'), {
              mission: this.mission
            });
            return false;
          }
        }
        return this.logger.debug("[after_action]: window.appController.mission_saved_flag " + window.appController.mission_saved_flag);
      };

      AppController.prototype.refreshSelectableAndSelectedLayers = function() {
        $('.ms-list').empty();
        $('#my-select').empty();
        _.each(this.mission.get('available_layers'), (function(a_layer, layer_index) {
          return $('#my-select').append("<option value='" + a_layer.name + "-----" + (Math.random() * 10e16) + "'>" + a_layer.name + "</option>");
        }), this);
        $('#my-select').prepend("<option value='PALLET' selected>0: PALLET</option>");
        _.each(window.appController.getUsedLayersOrder(), (function(a_layer, layer_index) {
          return $('#my-select').prepend("<option value=" + a_layer.option_value + " layer-index='" + layer_index + "' selected>" + (layer_index + 1) + ": " + a_layer.name + "</option>");
        }), this);
        return $('#my-select').multiSelect('refresh');
      };

      AppController.prototype.setBoard = function(newBoard) {
        return this.board = newBoard;
      };

      AppController.prototype.getLayers = function() {
        return this.mission.get('available_layers');
      };

      AppController.prototype.addLayer = function(new_layer) {
        this.mission.addLayer(new_layer);
        this.routine_request({
          name: 'resetBoxes'
        });
        this.routine_request({
          name: 'resetLayers'
        });
        return this.sendLayersToSave();
      };

      AppController.prototype.removeLayer = function(layer_data) {
        this.mission.removeLayer(layer_data.id);
        this.routine_request({
          name: 'resetBoxes'
        });
        this.routine_request({
          name: 'resetLayers'
        });
        this.sendLayersToSave();
        this.routine_request({
          name: 'resetUsedLayers'
        });
        this.sendUsedLayersToSave();
        return window.appController.mission_saved_flag = false;
      };

      AppController.prototype.saveLayerBy = function(layer_params) {
        if (layer_params.id === void 0) {
          layer_params.id = "layer-item-" + layer_params.name + "-" + (Math.random() * 10e17);
        }
        if (layer_params.ulid === void 0) {
          layer_params.ulid = "" + layer_params.name + "------ulid" + (Math.random() * 10e17);
        }
        this.addLayer(layer_params);
        return window.appController.mission_saved_flag = false;
      };

      AppController.prototype.getAvailableLayersOrder = function() {
        return this.mission.getAvailableLayersOrder();
      };

      AppController.prototype.addToUsedLayers = function(layer_name, layer_option_value, layer_ulid) {
        return this.mission.addToUsedLayers(layer_name, layer_option_value, layer_ulid);
      };

      AppController.prototype.getUsedLayersOrder = function() {
        return this.mission.getUsedLayersOrder();
      };

      AppController.prototype.removeFromUsedLayers = function(layer_option_value) {
        this.mission.removeFromUsedLayers(layer_option_value);
        return window.appController.mission_saved_flag = false;
      };

      AppController.prototype.load_pattern_data = function(layer_data) {
        if (layer_data !== void 0) {
          $('#layer-name').val(layer_data.name);
          return _.each(layer_data.boxes, function(a_box) {
            return window.appController.board.boxes.createNewBox(a_box);
          });
        }
      };

      AppController.prototype.getUlidByName = function(layer_name) {
        return this.mission.getLayerDataByName(layer_name).ulid;
      };

      AppController.prototype.updateUsedLayersNameByUlid = function(new_layer_name, layer_ulid) {
        this.mission.updateUsedLayersNameByUlid(new_layer_name, layer_ulid);
        this.routine_request({
          name: 'resetBoxes'
        });
        this.routine_request({
          name: 'resetLayers'
        });
        this.sendLayersToSave();
        this.routine_request({
          name: 'resetUsedLayers'
        });
        return this.sendUsedLayersToSave();
      };

      AppController.prototype.sendLayersToSave = function() {
        var available_layers;
        available_layers = this.mission.get('available_layers');
        return _.each(available_layers, ((function(_this) {
          return function(a_layer) {
            var layer_boxes, layer_name;
            if (a_layer.name !== 'SHEET') {
              layer_name = a_layer.name;
              layer_boxes = a_layer.boxes;
              _this.routine_request({
                name: 'addNewLayer',
                params: [layer_name]
              });
              return _.each(layer_boxes, (function(a_box) {
                _this.set_request({
                  name: 'request_box.x',
                  value: a_box.x
                });
                _this.set_request({
                  name: 'request_box.y',
                  value: a_box.y
                });
                _this.set_request({
                  name: 'request_box.arrow',
                  value: a_box.arrow
                });
                _this.set_request({
                  name: 'request_box.arrowEnabled',
                  value: a_box.arrowEnabled.toString()
                });
                _this.set_request({
                  name: 'request_box.layer_name',
                  value: layer_name,
                  type: 'str'
                });
                _this.set_request({
                  name: 'request_box.rotate',
                  value: a_box.rotate
                });
                return _this.routine_request({
                  name: 'addNewBox'
                });
              }), _this);
            }
          };
        })(this)), this);
      };

      AppController.prototype.sendUsedLayersToSave = function() {
        var used_layers;
        used_layers = this.mission.get('used_layers');
        return _.each(used_layers, ((function(_this) {
          return function(a_layer) {
            return _this.routine_request({
              name: 'addNewUsedLayer',
              params: [a_layer.name]
            });
          };
        })(this)), this);
      };

      AppController.prototype.default_pattern_params = function() {
        var box, canvasStage, color, pallet, params;
        canvasStage = {
          width: 280,
          height: 360,
          stage_zoom: 1.5
        };
        color = {
          stage: {
            red: 255,
            green: 255,
            blue: 255
          },
          pallet: {
            red: 251,
            green: 209,
            blue: 175
          },
          overhang: {
            stroke: {
              red: 238,
              green: 49,
              blue: 109,
              alpha: 0.5
            }
          },
          boxPlaced: {
            inner: {
              red: 79,
              green: 130,
              blue: 246,
              alpha: 0.8,
              stroke: {
                red: 147,
                green: 218,
                blue: 87,
                alpha: 0.5
              }
            },
            outer: {
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0,
              stroke: {
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0
              }
            }
          },
          boxSelected: {
            collision: {
              inner: {
                red: 255,
                green: 0,
                blue: 0,
                alpha: 1,
                stroke: {
                  red: 147,
                  green: 218,
                  blue: 87,
                  alpha: 0.5
                }
              },
              outer: {
                red: 255,
                green: 0,
                blue: 0,
                alpha: 0.5,
                stroke: {
                  red: 255,
                  green: 0,
                  blue: 0,
                  alpha: 0.5
                }
              }
            },
            uncollision: {
              inner: {
                red: 108,
                green: 153,
                blue: 57,
                alpha: 1,
                stroke: {
                  red: 72,
                  green: 82,
                  blue: 38,
                  alpha: 0.5
                }
              },
              outer: {
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0,
                stroke: {
                  red: 70,
                  green: 186,
                  blue: 3,
                  alpha: 0.5
                }
              }
            }
          }
        };
        pallet = {
          width: this.mission.get('pallet_length'),
          height: this.mission.get('pallet_width'),
          overhang: this.mission.get('overhang_len')
        };
        box = {
          x: 0,
          y: 0,
          width: this.mission.get('box_length'),
          height: this.mission.get('box_width'),
          minDistance: this.mission.get('mini_distance')
        };
        params = {
          pallet: pallet,
          box: box,
          stage: canvasStage,
          color: color
        };
        return params;
      };

      return AppController;

    })();
    return {
      create: new AppController
    };
  });

}).call(this);

/*
//@ sourceMappingURL=appController.js.map
*/
