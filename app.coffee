"use strict"
###### rivets adapter configure, below ######
rivets.adapters[":"] =
  subscribe: (obj, keypath, callback) ->
    console.log("1.subscribe:\t #{obj} ||\t #{keypath}")
    obj.on "change:" + keypath, callback
    return

  unsubscribe: (obj, keypath, callback) ->
    console.log("2.unsubscribe:\t #{obj} ||\t #{keypath}")
    obj.off "change:" + keypath, callback
    return

  read: (obj, keypath) ->
    console.log("3.read:\t\t\t #{obj} ||\t #{keypath}")
    # if((obj.get keypath) == undefined)
    #   console.log("3.read:++ #{obj[keypath]()} \t #{(obj.get keypath)}")
    #   obj[keypath]()
    # else
    #   obj.get keypath
    obj.get keypath

  publish: (obj, keypath, value) ->
    console.log("4.publish:\t\t #{obj} ||\t #{keypath}")
    obj.set keypath, value
    return

###### rivets adapter configure, above######


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
    boxId:        '9999'
    fillColor:    {red:60, green:118, blue: 61}
  }
  initialize: ->
    @on('change:rect', @rectChanged)
    #Fill Color: rgb(60, 118, 61)
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
  updateRectStyle: (options) ->
    Logger.debug("updateRectStyle: #{@getTitleName()}")
    @get('rect').setFill(options.color)

  rectChanged:() ->
    Logger.debug('box model changed by rect.')
  box: ->
    @get('group')
  printPoints: ->
    Logger.debug("PointA(x:#{@getPointA().x},y:#{@getPointA().y}) " +
                "PointB(x:#{@getPointB().x},y:#{@getPointB().y}) " +
                "PointC(x:#{@getPointC().x},y:#{@getPointC().y}) " +
                "PointD(x:#{@getPointD().x},y:#{@getPointD().y}) ")

class CollisionPool
#   # store ONLY *box ID*
#   constructor: ->
#     @pairs = []
#     @existBoxes = []
#   add: (box) ->
#     if @existBoxes.length > 1
#       @makePair
#     else
  
#   makePair:


class @Boxes extends Backbone.Collection
  model: Box
  initialize: (@layer,@zone)->
    @on('add', @showCurrentBoxPanel)
    @currentBox = new Box
    @availableNewBoxId = 1
    @flash = "Initialized completed!"
    @_collisionPool = new CollisionPool

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
    Logger.debug("...Collision start...")
    result =_.reduce(@models,
                    ((status, box) ->
                      if @currentBox.getTitleName() != box.getTitleName()
                        # Logger.debug("start testCollision box: #{box.getTitleName()} currentBox: #{@currentBox.getTitleName()}")
                        @testBoxCollision(@currentBox, box) || status
                      else
                        # Logger.debug("not testCollision box: #{box.getTitleName()} currentBox: #{@currentBox.getTitleName()}")
                        status), 
                    false, this)
    Logger.debug("...Collision result: #{result}")
  draw: () ->
    for box in @models
      Logger.debug("In draw: Box#{box.getTitleName()}.color=#{box.get('rect').getFill()}")
      @layer.add(box.box())
    @layer.draw()
  testBoxCollision: (boxA, boxB) ->
    status  =     false
    boxATop =     boxA.getYPosition()
    boxABottom =  boxA.getYPosition() + boxA.getHeight()
    boxALeft   =  boxA.getXPosition()
    boxARight  =  boxA.getXPosition() + boxA.getWidth()
    boxBTop    =  boxB.getYPosition()
    boxBBottom =  boxB.getYPosition() + boxB.getHeight()
    boxBLeft   =  boxB.getXPosition()
    boxBRight  =  boxB.getXPosition() + boxB.getWidth()
    status = true  unless boxABottom < boxBTop or boxATop > boxBBottom or boxALeft > boxBRight or boxARight < boxBLeft
#    Logger.debug("\tboxA: #{boxA.getTitleName()}, boxB: #{boxB.getTitleName()}")
#    Logger.debug("\tstatus: #{status}")
    if status
      # collision happened
      @updateBoxStyle(boxA, {collision: true, collisionBox: boxB})
    else
      @updateBoxStyle(boxA, {recoverFillColor: true})
    status

  updateBoxStyle: (boxA, options) ->
    if options.collision
      options.collisionBox.updateRectStyle({color: 'yellow'})
      boxA.updateRectStyle({color: 'yellow'})
    if options.recoverFillColor
      boxA.updateRectStyle({color: 'green'})
    @draw()

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

# class @Boxes2
#   initialize: (options)->
#     @set boxes: new Boxes(options)



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
    # @boxes2 = new Boxes(layer: @layer,zone: @zone)
    # rivets.bind $('.boxes'),{boxes: @boxes2.get('boxes')}
board = new StackBoard


########  TEST  #########

## http://jsfiddle.net/EAvXT/8/

# class Item extends Backbone.Model
#   initialize: ->
#     @set ttext: 'dddd'
#     @on 

#   GetText: ->
#     # console.log this
#     @get("Name") + " | $" + @get("Price")

#   desc: ->
#     # console.log this
#     @get("Name") + " -- $" + @get("Price")
#   Edit: =>
#     console.log this
#     @trigger "edit", this
#     return

# ItemCollection = Backbone.Collection.extend(model: Item)
# ItemView = Backbone.View.extend(
#   templateId: "#editItemDialog"
#   events:
#     "click .close-link": "close"

#   render: ->
#     templateFunction = _.template($(@templateId).html())
#     html = templateFunction()
#     @setElement html
#     rivets.bind @$el,
#       item: @model

#     this

#   close: ->
#     @$el.empty()
#     return
# )
# Store = Backbone.Model.extend(initialize: (options) ->
#   @set
#     Title: "Cyclist Stuff"
#     Items: options.Items

#   return
# )
# editUsingViews = (item) ->
#   view = new ItemView(model: item)
#   $("#holder").empty().append view.render().el
#   false

# storeItems = _.map([
#   {
#     Name: "Awesome Carbon Wheels"
#     Price: "100"
#     Description: "Something to covet for a cyclist"
#   }
#   {
#     Name: "Speedplay Pedals"
#     Price: "10"
#     Description: "Something else to covet for a cyclist"
#   }
#   {
#     Name: "LOTOJA"
#     Price: "25"
#     Description: "Big bike ride"
#   }
# ], (obj) ->
#   item = new Item(obj)
#   console.log item.get('Name')
#   item.on "edit", editUsingViews
#   item
# )

# rivets.formatters.currency =
#   read: (value) ->
#     (value / Math.pow(10, 2)).toFixed 2

#   publish: (value) ->
#     Math.round parseFloat(value) * Math.pow(10, 2)


# @storeItemsCollection = new ItemCollection(storeItems)
# @store = new Store(Items: @storeItemsCollection)


# rivets.bind $("#store1"),
#   store: @store
#   storeItems: @storeItemsCollection



