define [
  "jquery"
  "underscore"
  "backbone"
  "views/missions/index"
], ($, _, Backbone, MissionIndexView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "missionIndex"
      "pattern": "patternIndex"
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
      patternIndexView = new PatternIndexView
      patternIndexView.render()
      return

    show: (id) ->
      $(document.body).append "Show route has been called.. with id equals : ", id
      return

    download: (random) ->
      $(document.body).append "download route has been called.. with random equals : ", random
      return


  initialize: new AppRouter
