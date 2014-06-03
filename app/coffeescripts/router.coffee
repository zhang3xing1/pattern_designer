define [
  "jquery"
  "underscore"
  "backbone"
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
], ($, _, Backbone, MissionShowView, PatternIndexView, FrameShowView, 
  LineinShowView, LineoutShowView, MissionEditView, MissionIndexView, MissionNewView,
  BoxSettingView, PlaceSettingView, PickSettingView, AdditionalInfoView,
  PalletSettingView, ConstraintSettingView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "missionShow"
      "pattern": "patternIndex"
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



      "show/:id": "show"
      "download/*random": "download"
          
    initialize: ->
      Backbone.history.start()

    missionShow: ->
      console.log 'missionShow'
      $('.right_board').remove()
      missionShowView = new MissionShowView
      missionShowView.render()
      return
      
    patternIndex: ->
      console.log 'patternIndex'
      $('.right_board').remove()
      patternIndexView = new PatternIndexView
      patternIndexView.render()
      return

    frameShow: ->
      console.log 'frameShow'
      $('.right_board').remove()
      frameShowView = new FrameShowView
      frameShowView.render()

    lineinShow: ->
      console.log 'lineinShow' 
      $('.right_board').remove()
      lineinShowView = new LineinShowView
      lineinShowView.render()

    lineoutShow: ->
      console.log 'lineoutShow' 
      $('.right_board').remove()
      lineoutShowView = new LineoutShowView
      lineoutShowView.render()  

    missionEdit: ->
      console.log 'missionEdit' 
      $('.right_board').remove()
      missionEditView = new MissionEditView
      missionEditView.render() 
      $('#my-select').multiSelect()

    missionIndex: ->
      console.log 'missionIndex'
      $('.right_board').remove()
      missionIndexView = new MissionIndexView
      missionIndexView.render()    
      
      option =
        trigger: $("#Rename")
        action: "click"

      console.log option

      $("#mission_0001").editable option, (e) ->
        console.log "rename worked!"
        return

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

    show: (id) ->
      $(document.body).append "Show route has been called.. with id equals : ", id
      return

    download: (random) ->
      $(document.body).append "download route has been called.. with random equals : ", random
      return


  initialize: new AppRouter
