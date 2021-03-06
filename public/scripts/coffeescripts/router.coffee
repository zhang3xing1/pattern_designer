define [
  "jquery"
  "underscore"
  "backbone"
  "appController"
  "backboneRoutefilter"
  "tinybox"
  "logger"
  "jqueryTransit"
  "views/missions/show"
  "views/pattern/index"
  "views/frame/show"
  "views/linein/show"
  "views/lineout/show"
  "views/missions/edit"
  "views/missions/index"
  "views/missions/new"  
  "views/linein/boxSetting"
  "views/linein/placeSetting"
  "views/linein/pickSetting"
  "views/linein/toolSetting"
  "views/linein/additionalInfo"
  "views/lineout/palletSetting"
  "views/lineout/constraintSetting"
  "views/pattern/show"
  "views/lineout/palletTemplate"
  "views/linein/tools"
  "views/linein/calculateTool"
], ($, _, Backbone, AppController, BackboneRoutefilter, Tinybox, Logger, JqueryTransit, MissionShowView, PatternIndexView, FrameShowView, 
  LineinShowView, LineoutShowView, MissionEditView, MissionIndexView, MissionNewView,
  BoxSettingView, PlaceSettingView, PickSettingView, ToolSettingView, AdditionalInfoView,
  PalletSettingView, ConstraintSettingView, PatternShowView, PalletTemplateView, ToolsView, CalculateToolView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "missionShow"
      "pattern/*action": "pattern"
      "frame":   "frameShow"
      "linein":  "lineinShow"
      "lineout":  "lineoutShow"
      'mission/*action':  "mission_"
      'boxSetting': 'boxSetting'
      'boxSetting': 'boxSetting'
      'placeSetting': 'placeSetting'
      'pickSetting': 'pickSetting'
      'toolSetting': 'toolSetting'
      'additionalInfo': 'additionalInfo'
      'palletSetting' : 'palletSetting'
      'palletTemplate' : 'palletTemplate'
      'constraintSetting': 'constraintSetting'
      "patterns": "patternIndex"
      'tool/*action': 'tool'
      'tools': 'tools'
      'calculateTool':'calculateTool'

      # default root router
      "": "missionShow"

    initialize: ->
      # other router will not refresh view
      @appData = 
        debugInfo: "hello, this is app data debug info"
      @logger = Logger.create  

      # initialize only one appController
      window.appController = AppController.create
      Backbone.history.start()

    tool: ->
      return  

    missionShow: ->
      $('.right_board').remove()
      missionShowView = new MissionShowView({app: @appData})
      missionShowView.render()

    patternIndex: ->
      $('.right_board').remove()
      patternIndexView = new PatternIndexView
      patternIndexView.render()
      return

    pattern: (action)->
      if action == 'new'
        $('.right_board').remove()
        patternShowView = new PatternShowView
        patternShowView.render()

      if action == 'edit'
        selected_layer_name = window.appController.get_selected_layer_name()
        if selected_layer_name == ''
          @navigate("patterns", {trigger: true})
          return false
        else
          $('.right_board').remove()
          patternShowView = new PatternShowView
          patternShowView.render()

      if action == 'delete'
        selected_layer_name = window.appController.get_selected_layer_name()
        if selected_layer_name != ''
          selected_layer = window.appController.mission.getLayerDataByName(selected_layer_name)
          window.appController.removeLayer(selected_layer)
        else
          window.appController.flash(message: 'Delete a layer after choosing it!')

        @navigate("patterns", {trigger: true})
        return false      
      if action == 'info'
        selected_layer_id = $('.list-group-item.selected-item').html()
        if selected_layer_id != '' and selected_layer_id != undefined
          # window.appController.setSelectedLayer(selected_layer_id)
          # $('.right_board').remove()
          # patternShowView = new PatternShowView
          # patternShowView.render()
        else
          @navigate("patterns", {trigger: true})
          return false  

    frameShow: ->
      
      $('.right_board').remove()
      frameShowView = new FrameShowView
      frameShowView.render()

    lineinShow: ->
      $('.right_board').remove()
      lineinShowView = new LineinShowView
      lineinShowView.render()

    lineoutShow: -> 
      $('.right_board').remove()
      lineoutShowView = new LineoutShowView
      lineoutShowView.render()  

    mission_: (action) ->
      if action == 'edit'
        $('.right_board').remove()
        missionEditView = new MissionEditView
        missionEditView.render() 
        # $('#my-select').multiSelect()

      if action == 'new'
        console.log 'missionNew'
        $('.right_board').remove()
        missionNewView = new MissionNewView
        missionNewView.render() 

      if action == 'index'
        # $('.right_board').remove()
        $('.right_board').addClass('previous-page')
        missionIndexView = new MissionIndexView
        missionIndexView.render() 
        $('.sub-page-view').transition({ left: '0px' });
        window.setTimeout((->
          $('.previous-page').remove()
          ), 1000);
        

      if action == 'save'
        window.appController.mission_saved_flag = true

    boxSetting: ->
      console.log 'boxSetting'
      $('.right_board').remove()

      boxSettingView = new BoxSettingView
      boxSettingView.render()  

    toolSetting: ->
      console.log 'toolSetting'
      $('.right_board').remove()
      toolSettingView = new ToolSettingView
      toolSettingView.render() 
      $("[name='teach']").bootstrapSwitch('onColor', 'success') 

    pickSetting: ->
      console.log 'pickSetting'
      $('.right_board').remove()
      pickSettingView = new PickSettingView
      pickSettingView.render() 
      $("[name='teach']").bootstrapSwitch('onColor', 'success') 


    placeSetting: ->
      console.log 'placeSetting'
      $('.right_board').remove()
      placeSettingView = new PlaceSettingView
      placeSettingView.render()   
      $("[name='orient']").bootstrapSwitch('onColor', 'success') 

    additionalInfo: ->
      console.log 'additionalInfo'
      $('.right_board').remove()
      additionalInfoView = new AdditionalInfoView
      additionalInfoView.render()   
      $("[name='length']").bootstrapSwitch('onColor', 'success')  
      $("[name='cross']").bootstrapSwitch('onColor', 'success') 

    palletSetting: ->
      console.log 'palletSetting'
      $('.right_board').remove()
      palletSettingView = new PalletSettingView
      palletSettingView.render()           

    palletTemplate: ->
      console.log 'palletTemplate'
      $('.right_board').remove()
      PalletTemplateShow = new PalletTemplateView
      PalletTemplateShow.render() 

    tools: ->
      console.log 'tools'
      $('.right_board').remove()
      ToolsShow = new ToolsView
      ToolsShow.render() 

    calculateTool: ->
      console.log 'calculateTool'
      $('.right_board').remove()
      CalculateToolShow = new CalculateToolView
      CalculateToolShow.render()     

    constraintSetting: ->
      console.log 'constraintSetting'
      $('.right_board').remove()
      constraintSettingView = new ConstraintSettingView
      constraintSettingView.render()     

    ######################################################
    #
    #
    # Route callback for validating and filtering data.
    #
    #
    ######################################################

    before: (route, params) ->
      @logger.dev("[Before] - route: #{route}, params: #{params}")
      return window.appController.before_action(route, params)
      
    after: (route, params) ->
      ## Change left nav button color
      $('.left-nav-list').removeClass('list-group-item-info')
      # $("[href*='linein']")
      $("#left_board [href*='#{route}']").addClass('list-group-item-info')

      @logger.debug("[After] - route: #{route}, params: #{params}")

      window.appController.after_action(route, params)
      # $('#app-flash').modal()
      # @navigate("loadMission", {trigger: true});

  initialize: new AppRouter
