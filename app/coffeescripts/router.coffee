define [
  "jquery"
  "underscore"
  "backbone"
], ($, _, Backbone) ->
  class AppRouter extends Backbone.Router
    routes:
      "test1": "index"
      "show/:id": "show"
      "download/*random": "download"
          
    initialize: ->
      Backbone.history.start()

    index: ->
      alert 'yoooo'
      $(document.body).append "Index route has been called.."
      return

    show: (id) ->
      $(document.body).append "Show route has been called.. with id equals : ", id
      return

    download: (random) ->
      $(document.body).append "download route has been called.. with random equals : ", random
      return


  initialize: new AppRouter
