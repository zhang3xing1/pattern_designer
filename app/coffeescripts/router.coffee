define [
  "jquery"
  "underscore"
  "backbone"
  "views/missions/index"
  "views/pattern/index"
  "views/frame/show"
  "views/linein/show"
  "views/lineout/show"
  "views/missions/edit"
], ($, _, Backbone, MissionIndexView, PatternIndexView, FrameShowView, LineinShowView, LineoutShowView, MissionEditView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "missionIndex"
      "pattern": "patternIndex"
      "frame":   "frameShow"
      "linein":  "lineinShow"
      "lineout":  "lineoutShow"
      'mission':  "missionEdit"
      
      "show/:id": "show"
      "download/*random": "download"
          
    initialize: ->
      Backbone.history.start()

    missionIndex: ->
      console.log 'missionIndex'
      $('.right_board').remove()
      missionIndexView = new MissionIndexView
      missionIndexView.render()
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
      console.log 'lineoutShow' 
      $('.right_board').remove()
      missionEditView = new MissionEditView
      missionEditView.render() 
      $('#my-select').multiSelect()
    show: (id) ->
      $(document.body).append "Show route has been called.. with id equals : ", id
      return

    download: (random) ->
      $(document.body).append "download route has been called.. with random equals : ", random
      return


  initialize: new AppRouter
