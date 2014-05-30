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
], ($, _, Backbone, MissionShowView, PatternIndexView, FrameShowView, LineinShowView, LineoutShowView, MissionEditView, MissionIndexView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "missionShow"
      "pattern": "patternIndex"
      "frame":   "frameShow"
      "linein":  "lineinShow"
      "lineout":  "lineoutShow"
      'mission':  "missionEdit"
      'loadMission':  "missionIndex"
      
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
    show: (id) ->
      $(document.body).append "Show route has been called.. with id equals : ", id
      return

    download: (random) ->
      $(document.body).append "download route has been called.. with random equals : ", random
      return


  initialize: new AppRouter
