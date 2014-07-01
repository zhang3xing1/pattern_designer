define [
  "jquery"
  "underscore"
  "backbone"
  "backboneRoutefilter"
  "logger"
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
  "views/linein/additionalInfo"
  "views/lineout/palletSetting"
  "views/lineout/constraintSetting"
  "views/pattern/show"
], ($, _, Backbone, BackboneRoutefilter, Logger, MissionShowView, PatternIndexView, FrameShowView, 
  LineinShowView, LineoutShowView, MissionEditView, MissionIndexView, MissionNewView,
  BoxSettingView, PlaceSettingView, PickSettingView, AdditionalInfoView,
  PalletSettingView, ConstraintSettingView, PatternShowView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "missionShow"
      "pattern": "patternShow"
      "frame":   "frameShow"
      "linein":  "lineinShow"
      "lineout":  "lineoutShow"
      'mission':  "missionEdit"
      'loadMission':  "missionIndex"
      'createMission':  "missionNew"
      'boxSetting': 'boxSetting'
      'boxSetting': 'boxSetting'
      'placeSetting': 'placeSetting'
      'pickSetting': 'pickSetting'
      'additionalInfo': 'additionalInfo'
      'palletSetting' : 'palletSetting'
      'constraintSetting': 'constraintSetting'
      "patterns": "patternIndex"

      # default root router
      "": "missionShow"
      # "download/*random": "download"
          
    initialize: ->
      @appData = 
        debugInfo: "hello, this is app data debug info"
      @logger = Logger.create  
      Backbone.history.start()

    missionShow: ->
      $('.right_board').remove()
      missionShowView = new MissionShowView({app: @appData})
      missionShowView.render()
      return
      
    patternIndex: ->
      $('.right_board').remove()
      patternIndexView = new PatternIndexView
      patternIndexView.render()
      return

    patternShow: ->
      $('.right_board').remove()
      patternShowView = new PatternShowView
      patternShowView.render()
      return

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

    missionEdit: ->
      $('.right_board').remove()
      missionEditView = new MissionEditView
      missionEditView.render() 
      $('#my-select').multiSelect()

    missionIndex: ->
      $('.right_board').remove()
      missionIndexView = new MissionIndexView
      missionIndexView.render()    
      
      # option =
      #   trigger: $("#Rename")
      #   action: "click"

      #    # $("#mission_0001").editable option, (e) ->
      #   console.log "rename worked!"
      #   return

    missionNew: ->
      console.log 'missionNew'
      $('.right_board').remove()
      missionNewView = new MissionNewView
      missionNewView.render() 

    boxSetting: ->
      console.log 'boxSetting'
      $('.right_board').remove()
      boxSettingView = new BoxSettingView
      boxSettingView.render()  

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
      $("[name='teach']").bootstrapSwitch('onColor', 'success')  

    palletSetting: ->
      console.log 'palletSetting'
      $('.right_board').remove()
      palletSettingView = new PalletSettingView
      palletSettingView.render()           

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


    after: (route, params) ->
      ## Change left nav button color
      $('.left-nav-list').removeClass('list-group-item-info')
      # $("[href*='linein']")
      $("#left_board [href*='#{route}']").addClass('list-group-item-info')

      #
      @logger.dev("[After] - route: #{route}, params: #{params}")

  initialize: new AppRouter
