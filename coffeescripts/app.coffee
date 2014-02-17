class @Logger
  instance = null
  class Horn
    info: (message) -> 
      'INFO:\t' + message
    debug: (message) -> 
      'DEBUG:\t' + message
  @info: (message) ->
    instance ?= new Horn
    console.log(instance.info(message))
  @debug: (message) ->
    instance ?= new Horn
    console.log(instance.debug(message))

class @Box extends Backbone.Model
  defaults: {
    boxId:   '9999'
  }
  initialize: ->
    @on('change:rect', @rectChanged)
    @set rect: new Kinetic.Rect(
                                  x:            10
                                  y:            20
                                  width:        100
                                  height:       50
                                  fill:         "green"
                                  # stroke:       'blue'
                                )
    @set title: new Kinetic.Text(
                                  x:            @get('rect').x() + @get('rect').width()/2  - 5
                                  y:            @get('rect').y() + @get('rect').height()/2 - 5
                                  fontSize:     14
                                  fontFamily:   "Calibri"
                                  fill:         "white"
                                  text:         @get('boxId')
                                )
    @set group: new Kinetic.Group(
                                  x: 10
                                  y: 20
                                  rotation: 0
                                )
    @get('group').add(@get('rect'))
    @get('group').add(@get('title'))
    Logger.debug('Box: Generate a new box.')
    @get('group').on "click", ->
      Logger.debug @getX()

  setTitleName: (newTitle) ->
    @get('title').setText(newTitle) 
  getTitleName: () ->
    @get('title').text() 
  setXPosition: (x) ->
    @get('group').setX(x)
  getXPosition: () ->
    @get('group').x()
  setYPosition: (y) ->
    @get('group').setY(y)
  getYPosition: ()  ->
    @get('group').y()
  setHeight: (height) ->
    @get('rect').setHeight(height)
  getHeight:  ->
    @get('rect').height()
  setWidth: (width) ->
    @get('rect').setWidth(width)
  getWidth: () ->
    @get('rect').width()
  rectChanged:() ->
    Logger.debug('box model changed by rect.')

  box: ->
    @get('group')


class @Boxes extends Backbone.Collection
  model: Box

  initialize: (@layer)->
    @on('add', @showCurrentBox)
    @currentBox = new Box
    @currentNewBoxId  = 1
    @flash = "Initialized completed!"
    @flash = 'test:\t' + @currentBox.get('boxId')
  addNewBox: =>

    Logger.debug('show currentbox x:\t' + @currentBox.getXPosition())
    newBox  = new Box
    newBox.setXPosition(newBox.getXPosition() + @currentNewBoxId * 10 )
    newBox.setYPosition(newBox.getYPosition() + @currentNewBoxId * 10 )
    newBox.setTitleName(@currentNewBoxId)
    newBox.set('boxId', @currentNewBoxId)
    @currentBox = newBox
    @add(newBox)
    @draw()
    # _.last(@models)
    @currentBox = new Box
    @currentNewBoxId += 1
  testCollision:()->
    ;
  draw: () ->
    for box in @models
      @layer.add(box.box())
    @layer.draw()
  testBoxCollision: (boxA, boxB) ->
    status  =     false
    boxATop =     boxA.getXPosition()
    boxABottom =  boxA.getYPosition() + boxA.getHeight()
    boxALeft   =  boxA.getXPosition()
    boxARight  =  boxA.getXPosition() + boxA.getWidth()
    boxBTop    =  boxB.getYPosition()
    boxBBottom =  boxB.getYPosition() + boxB.getHeight()
    boxBLeft   =  boxB.getXPosition()
    boxBRight  =  boxB.getXPosition() + boxB.getWidth()
    status = true  unless boxABottom < boxBTop or boxATop > boxBBottom or boxALeft > boxBRight or boxARight < boxBLeft
    status
  showCurrentBox: () =>
    rivets.bind $('.box'),{box: @currentBox}
    Logger.debug('show currentbox x:\t' + @currentBox.getXPosition())
    if(_.isEmpty(@models))
      $('.box').css('display','none')
    else
      $('.box').css('display','block')
class @StackBoard
  constructor: ->
    @stage = new Kinetic.Stage(
      container: "canvas_container"
      width: 300  
      height: 360
    )
    @layer = new Kinetic.Layer()
    @stage.add @layer
    Logger.debug("StackBoard: Stage Initialized!")
    Logger.info("StackBoard: Initialized!")
    @boxes = new Boxes(@layer)
    @boxes.shift()
    rivets.bind $('.boxes'),{boxes: @boxes}



board=new StackBoard
# rivets.binders.color = (el, value) ->
#   el.style.color = value

# rivets.bind $('.boxes'),{boxes: boxes}
# test
# BINDING BACKBONE.JS MODEL(S) TO A VIEW
# user = new Backbone.Model(
#   name: "Joe"
# )
# class User extends Backbone.Model
#   defaults: {
#     name: "Joe"
#   }
#   add_u: ->
#     console.log('d')

# el = document.getElementById("user-view")
# rivets.bind el,
#   user: user=new User

# Canvas test

# stage = new Kinetic.Stage(
#   container: "canvas_container"
#   width: 300  
#   height: 360
# )
# layer = new Kinetic.Layer()
# rect = new Kinetic.Rect(
#   x: 10
#   y: 10
#   width: 20
#   height: 20
#   fill: "green"
#   strokeWidth: 4
# )

# # add the shape to the layer
# layer.add rect

# # add the layer to the stage
# stage.add layer

#
# Calculate the fibonacci numbers
#
# Warning: This script can go really slow if you try to calculate the number with n > 20
#

#
# Generate a RFC 4122 GUID
#
# See section 4.4 (Algorithms for Creating a UUID from Truly Random or
# Pseudo-Random Numbers) for generating a GUID, since we don't have
# hardware access within JavaScript.
#
# More info:
#
#   - http://www.rfc-archive.org/getrfc.php?rfc=4122
#   - http://www.broofa.com/2008/09/javascript-uuid-function/
#   - http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
#



