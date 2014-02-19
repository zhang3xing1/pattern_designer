"use strict"
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
    #rgb(60, 118, 61);
    @set rect: new Kinetic.Rect(
                                  x:            0
                                  y:            0
                                  width:        100
                                  height:       50
                                  fillRed:      60
                                  fillGreen:    118
                                  fillBlue:     61
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
                                  x: 4
                                  y: 8
                                  rotation: 0
                                )
    @get('group').add(@get('rect'))
    @get('group').add(@get('title'))
    Logger.debug('Box: Generate a new box.')

    @box().on "dblclick", =>
      @box().rotation(45)
      Logger.debug "@box().rotation(45)"

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
  getHeight:() ->
    @get('rect').height()
  setWidth: (width) ->
    @get('rect').setWidth(width)
  getWidth: () ->
    @get('rect').width()
  getPointA: () ->
    pointX = 
      x: @getXPosition()
      y: @getYPosition()
  getPointB: () ->
    pointB = 
      x: @getXPosition() + @get('rect').getWidth()
      y: @getYPosition()
  getPointC: () ->
    pointC = 
      x: @getXPosition()
      y: @getYPosition() + @get('rect').getHeight()
  getPointD: () ->
    pointC = 
      x: @getXPosition() + @get('rect').getWidth()
      y: @getYPosition() + @get('rect').getHeight()
  rectChanged:() ->
    Logger.debug('box model changed by rect.')

  box: ->
    @get('group')
  printPoints: ->
    Logger.info("PointA(x:#{@getPointA().x},y:#{@getPointA().y}) " +
                "PointB(x:#{@getPointB().x},y:#{@getPointB().y}) " +
                "PointC(x:#{@getPointC().x},y:#{@getPointC().y}) " +
                "PointD(x:#{@getPointD().x},y:#{@getPointD().y}) ")

class @Boxes extends Backbone.Collection
  model: Box
  initialize: (@layer,@zone)->
    @on('add', @showCurrentBoxPanel)
    @currentBox = new Box
    @availableNewBoxId  = 1
    @flash = "Initialized completed!"
  addNewBox: =>
    newBox  = new Box
    newBox.setXPosition(newBox.getXPosition() + @availableNewBoxId * 4 )
    newBox.setYPosition(newBox.getYPosition() + @availableNewBoxId * 4 )
    newBox.setTitleName(@availableNewBoxId)
    newBox.set('boxId', @availableNewBoxId)
    newBox.box().on "click", =>
      Logger.debug "box#{newBox.getTitleName()} clicked!"
      @updateCurrentBox(newBox)

    @add(newBox)
    @draw()
    
    @updateCurrentBox(newBox)
    @availableNewBoxId += 1

    Logger.debug("@availableNewBoxId:\t" + @availableNewBoxId)
  removeCurrentBox: =>
    if @length == 0
      @flash = 'There is no box.'
    else
      @currentBox.get('group').destroy()
      @remove(@currentBox)
      @currentBox = @last()
    @draw()
    if @length == 0
      @flash = 'There is no box.'
    @showCurrentBoxPanel()
    Logger.debug("remove button clicked!")
  testCollision:()->
    result =_.reduce(@models,
                    ((status, box) ->
                      if @currentBox.getTitleName() != box.getTitleName()
                        Logger.debug("testCollision #{@currentBox.getTitleName()} #{box.getTitleName()}")
                        status || @testBoxCollision(box, @currentBox)
                      else
                        status ), 
                    false, this)
    Logger.debug("testCollision: #{result}")
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
  updateCurrentBox: (newBox = @currentBox) ->
    @currentBox = newBox
    rivets.bind $('.box'),{box: newBox}
  showCurrentBoxPanel: () ->
    rivets.bind $('.box'),{box: @currentBox}
    Logger.debug("showCurrentBoxPanel: #{@length}")
    if(@length == 0)
      $('.panel').css('display','none')
    else
      $('.panel').css('display','block')
  up: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setYPosition(@currentBox.getYPosition() - 4)
    if @validateZone(@currentBox)
      @draw()
    else
      @currentBox.setYPosition(@currentBox.getYPosition() + 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved UP!"
    @currentBox.printPoints()
    @testCollision()
    @updateCurrentBox()
  down: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setYPosition(@currentBox.getYPosition() + 4)
    if @validateZone(@currentBox)
      @draw()
    else
      @currentBox.setYPosition(@currentBox.getYPosition() - 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved DOWN!"
    @currentBox.printPoints()
    @testCollision()
    @updateCurrentBox()
  left: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setXPosition(@currentBox.getXPosition() - 4)
    if @validateZone(@currentBox)
      @draw()
    else
      @currentBox.setXPosition(@currentBox.getXPosition() + 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved LEFT!"
    @currentBox.printPoints()
    @testCollision()
    @updateCurrentBox()
  right: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setXPosition(@currentBox.getXPosition() + 4)
    if @validateZone(@currentBox)
      @draw()
    else
      @currentBox.setXPosition(@currentBox.getXPosition() - 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved RIGHT!"
    @currentBox.printPoints()
    @testCollision()
    @updateCurrentBox()
  validateZone: (box) ->
    result = _.reduce([box.getPointA(),box.getPointB(),box.getPointC(),box.getPointD()], 
                ((status, point) ->
                  status && @validateZoneX(point) && @validateZoneY(point)), 
                  true, this)
    Logger.debug("validresult:\t #{result}")
    if result
      @flash = ""
    result
  validateZoneX: (point) ->
    Logger.debug("validateZoneX: point.x #{point.x}, @zone.x #{@zone.x}")
    0<= point.x <= @zone.x
  validateZoneY: (point) ->
    Logger.debug("validateZoneY: point.y #{point.y}, @zone.x #{@zone.y}")
    0<= point.y <= @zone.y

class @StackBoard
  constructor: ->
    @stage = new Kinetic.Stage(
      container: "canvas_container"
      width:  360
      height: 480
    )
    @zone = {x:300, y:380}
#    rgb(255,​ 228,​ 196)
    @layer = new Kinetic.Layer()
    stage_bg = new Kinetic.Rect(
        x:            0
        y:            0
        width:        300
        height:       380
        fillRed:      255
        fillGreen:    228
        fillBlue:     196
      )
    @layer.add stage_bg
    @stage.add @layer
    Logger.debug("StackBoard: Stage Initialized!")
    Logger.info("StackBoard: Initialized!")
    @boxes = new Boxes(@layer,@zone)
    @boxes.shift()
    rivets.bind $('.boxes'),{boxes: @boxes}

board=new StackBoard

#/====== Skip This Part, this is configuration =============
rivets.config.handler = (context, ev, binding) ->
  if binding.model instanceof binding.model.____
    @call binding.model, ev, context # Event Target !!
  else
    @call context, ev, binding.view.models

rivets.binders.input =
  publishes: true
  routine: rivets.binders.value.routine
  bind: (el) ->
    el.addEventListener "input", @publish
    return

  unbind: (el) ->
    el.removeEventListener "input", @publish
    return


#================ Acutal Code Start from Here =============
rivets.formatters.rupee = (val) ->
  "$ " + val

Person = ->
  @name = "Narendra"
  @job = {}

  @job.task = "Engineer"
  @____ = Person
  return

Person:: =
  show: ->
    @display()
    return

  change: ->
    @name = "Deepak"
    @job.task = "Playing"
    return

  display: ->
    alert JSON.stringify(this)
    return

  total: ->
    window.parseInt(@price) * window.parseInt(@quantity)

person = new Person()
rivets.bind document.querySelector("#asdasd"),
  scope: person

##### Example two way binding with rivets #####
# ///====== Skip This Part, this is configuration =============
# rivets.config.handler = function (context, ev, binding) {
#     if (binding.model instanceof binding.model.____) {
#         return this.call(binding.model, ev, context); // Event Target !!d
#     } else {
#         return this.call(context, ev, binding.view.models);
#     }
# };

# rivets.binders.input = {
#     publishes: true,d
#     routine: rivets.binders.value.routine,
#     bind: function (el) {
#         el.addEventListener('input', this.publish);
#     },
#     unbind: function (el) {
#         el.removeEventListener('input', this.publish);
#     }
# };

# //================ Acutal Code Start from Here =============
# rivets.formatters.rupee = function (val) {
#     return "$ " + val;
# };

# var Person = function () {
#     this.name = "Narendra",
#     this.job = {};
#     this.job.task = "Engineer";
#     this.____ = Person;
# };

# Person.prototype = {
#     show: function () {
#         this.display();
#     },
#     change: function () {
#         this.name = "Deepak";
#         this.job.task = "Playing";
#     },
#     display: function () {
#         alert(JSON.stringify(this));
#     },
#     total: function () {
#         return window.parseInt(this.price) * window.parseInt(this.quantity);
#     }
# };
################################################



# var person = new Person();
# rivets.bind(document.querySelector("#asdasd"), {
#     scope: person
# });

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



