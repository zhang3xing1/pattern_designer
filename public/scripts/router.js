(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "appController", "backboneRoutefilter", "tinybox", "logger", "jqueryTransit", "views/missions/show", "views/pattern/index", "views/frame/show", "views/linein/show", "views/lineout/show", "views/missions/edit", "views/missions/index", "views/missions/new", "views/linein/boxSetting", "views/linein/placeSetting", "views/linein/pickSetting", "views/linein/toolSetting", "views/linein/additionalInfo", "views/lineout/palletSetting", "views/lineout/constraintSetting", "views/pattern/show"], function($, _, Backbone, AppController, BackboneRoutefilter, Tinybox, Logger, JqueryTransit, MissionShowView, PatternIndexView, FrameShowView, LineinShowView, LineoutShowView, MissionEditView, MissionIndexView, MissionNewView, BoxSettingView, PlaceSettingView, PickSettingView, ToolSettingView, AdditionalInfoView, PalletSettingView, ConstraintSettingView, PatternShowView) {
    var AppRouter;
    AppRouter = (function(_super) {
      __extends(AppRouter, _super);

      function AppRouter() {
        return AppRouter.__super__.constructor.apply(this, arguments);
      }

      AppRouter.prototype.routes = {
        "program": "missionShow",
        "pattern/*action": "pattern",
        "frame": "frameShow",
        "linein": "lineinShow",
        "lineout": "lineoutShow",
        'mission/*action': "mission_",
        'boxSetting': 'boxSetting',
        'boxSetting': 'boxSetting',
        'placeSetting': 'placeSetting',
        'pickSetting': 'pickSetting',
        'toolSetting': 'toolSetting',
        'additionalInfo': 'additionalInfo',
        'palletSetting': 'palletSetting',
        'constraintSetting': 'constraintSetting',
        "patterns": "patternIndex",
        'tool/*action': 'tool',
        "": "missionShow"
      };

      AppRouter.prototype.initialize = function() {
        this.appData = {
          debugInfo: "hello, this is app data debug info"
        };
        this.logger = Logger.create;
        window.appController = AppController.create;
        return Backbone.history.start();
      };

      AppRouter.prototype.tool = function() {};

      AppRouter.prototype.missionShow = function() {
        var missionShowView;
        $('.right_board').remove();
        missionShowView = new MissionShowView({
          app: this.appData
        });
        return missionShowView.render();
      };

      AppRouter.prototype.patternIndex = function() {
        var patternIndexView;
        $('.right_board').remove();
        patternIndexView = new PatternIndexView;
        patternIndexView.render();
      };

      AppRouter.prototype.pattern = function(action) {
        var patternShowView, selected_layer, selected_layer_id, selected_layer_name;
        if (action === 'new') {
          $('.right_board').remove();
          patternShowView = new PatternShowView;
          patternShowView.render();
        }
        if (action === 'edit') {
          selected_layer_name = window.appController.get_selected_layer_name();
          if (selected_layer_name === '') {
            this.navigate("patterns", {
              trigger: true
            });
            return false;
          } else {
            $('.right_board').remove();
            patternShowView = new PatternShowView;
            patternShowView.render();
          }
        }
        if (action === 'delete') {
          selected_layer_name = window.appController.get_selected_layer_name();
          if (selected_layer_name !== '') {
            selected_layer = window.appController.mission.getLayerDataByName(selected_layer_name);
            window.appController.removeLayer(selected_layer);
          } else {
            window.appController.flash({
              message: 'Delete a layer after choosing it!'
            });
          }
          this.navigate("patterns", {
            trigger: true
          });
          return false;
        }
        if (action === 'info') {
          selected_layer_id = $('.list-group-item.selected-item').html();
          if (selected_layer_id !== '' && selected_layer_id !== void 0) {

          } else {
            this.navigate("patterns", {
              trigger: true
            });
            return false;
          }
        }
      };

      AppRouter.prototype.frameShow = function() {
        var frameShowView;
        $('.right_board').remove();
        frameShowView = new FrameShowView;
        return frameShowView.render();
      };

      AppRouter.prototype.lineinShow = function() {
        var lineinShowView;
        $('.right_board').remove();
        lineinShowView = new LineinShowView;
        return lineinShowView.render();
      };

      AppRouter.prototype.lineoutShow = function() {
        var lineoutShowView;
        $('.right_board').remove();
        lineoutShowView = new LineoutShowView;
        return lineoutShowView.render();
      };

      AppRouter.prototype.mission_ = function(action) {
        var missionEditView, missionIndexView, missionNewView;
        if (action === 'edit') {
          $('.right_board').remove();
          missionEditView = new MissionEditView;
          missionEditView.render();
        }
        if (action === 'new') {
          console.log('missionNew');
          $('.right_board').remove();
          missionNewView = new MissionNewView;
          missionNewView.render();
        }
        if (action === 'index') {
          $('.right_board').addClass('previous-page');
          missionIndexView = new MissionIndexView;
          missionIndexView.render();
          $('.sub-page-view').transition({
            left: '0px'
          });
        }
        if (action === 'save') {
          return window.appController.mission_saved_flag = true;
        }
      };

      AppRouter.prototype.boxSetting = function() {
        var boxSettingView;
        console.log('boxSetting');
        $('.right_board').remove();
        boxSettingView = new BoxSettingView;
        return boxSettingView.render();
      };

      AppRouter.prototype.toolSetting = function() {
        var toolSettingView;
        console.log('toolSetting');
        $('.right_board').remove();
        toolSettingView = new ToolSettingView;
        toolSettingView.render();
        return $("[name='teach']").bootstrapSwitch('onColor', 'success');
      };

      AppRouter.prototype.pickSetting = function() {
        var pickSettingView;
        console.log('pickSetting');
        $('.right_board').remove();
        pickSettingView = new PickSettingView;
        pickSettingView.render();
        return $("[name='teach']").bootstrapSwitch('onColor', 'success');
      };

      AppRouter.prototype.placeSetting = function() {
        var placeSettingView;
        console.log('placeSetting');
        $('.right_board').remove();
        placeSettingView = new PlaceSettingView;
        placeSettingView.render();
        return $("[name='orient']").bootstrapSwitch('onColor', 'success');
      };

      AppRouter.prototype.additionalInfo = function() {
        var additionalInfoView;
        console.log('additionalInfo');
        $('.right_board').remove();
        additionalInfoView = new AdditionalInfoView;
        additionalInfoView.render();
        $("[name='length']").bootstrapSwitch('onColor', 'success');
        return $("[name='cross']").bootstrapSwitch('onColor', 'success');
      };

      AppRouter.prototype.palletSetting = function() {
        var palletSettingView;
        console.log('palletSetting');
        $('.right_board').remove();
        palletSettingView = new PalletSettingView;
        return palletSettingView.render();
      };

      AppRouter.prototype.constraintSetting = function() {
        var constraintSettingView;
        console.log('constraintSetting');
        $('.right_board').remove();
        constraintSettingView = new ConstraintSettingView;
        return constraintSettingView.render();
      };

      AppRouter.prototype.before = function(route, params) {
        this.logger.dev("[Before] - route: " + route + ", params: " + params);
        return window.appController.before_action(route, params);
      };

      AppRouter.prototype.after = function(route, params) {
        $('.left-nav-list').removeClass('list-group-item-info');
        $("#left_board [href*='" + route + "']").addClass('list-group-item-info');
        this.logger.debug("[After] - route: " + route + ", params: " + params);
        return window.appController.after_action(route, params);
      };

      return AppRouter;

    })(Backbone.Router);
    return {
      initialize: new AppRouter
    };
  });

}).call(this);

/*
//@ sourceMappingURL=router.js.map
*/
