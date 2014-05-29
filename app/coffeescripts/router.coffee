define [
  "jquery"
  "underscore"
  "backbone"
  "views/program/index"
], ($, _, Backbone, ProgramCurrentView) ->
  class AppRouter extends Backbone.Router
    routes:
      "program": "programCurrentMission"
      "show/:id": "show"
      "download/*random": "download"
          
    initialize: ->
      Backbone.history.start()

    programCurrentMission: ->
      console.log 'yoooo'
      $('.right_board').remove()
      programCurrentView = new ProgramCurrentView
      programCurrentView.render()
      return

    show: (id) ->
      $(document.body).append "Show route has been called.. with id equals : ", id
      return

    download: (random) ->
      $(document.body).append "download route has been called.. with random equals : ", random
      return


  initialize: new AppRouter
