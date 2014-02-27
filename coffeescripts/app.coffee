# "use strict"
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
  statuses = ['info', 'debug', "dev"]
  # statuses = ['info']
  statuses = []
  class Horn
    info: (message) -> 
      'INFO:\t' + message
    debug: (message) -> 
      'DEBUG:\t' + message
    dev: (message) -> 
      'Dev:\t' + message
  @info: (message) ->
    if _.contains(statuses, 'info')
      instance ?= new Horn
      console.log(instance.info(message))
  @debug: (message) ->
    if _.contains(statuses, 'debug')
      instance ?= new Horn
      console.log(instance.debug(message))
  @dev: (message) ->
    if _.contains(statuses, 'dev')
      instance ?= new Horn
      console.log(instance.dev(message))

class @Box extends Backbone.Model
  defaults: {
    boxId:        'nullID'
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
      @box().rotation(90)
      Logger.debug "@box().rotation(90)"

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
  makeCollisionStatus: ->
    Logger.dev("box#{@getTitleName()}: makeCollisionStatus")
    @get('rect').setFill('red')
  makeUnCollisionStatus: ->
    Logger.dev("box#{@getTitleName()}: makeUnCollisionStatus")
    @get('rect').setFill('green')
  printPoints: ->
    Logger.debug("PointA(x:#{@getPointA().x},y:#{@getPointA().y}) " +
                "PointB(x:#{@getPointB().x},y:#{@getPointB().y}) " +
                "PointC(x:#{@getPointC().x},y:#{@getPointC().y}) " +
                "PointD(x:#{@getPointD().x},y:#{@getPointD().y}) ")


class @Boxes extends Backbone.Collection
  model: Box
  initialize: (@layer,@zone)->
    @on('add', @showCurrentBoxPanel)
    @on('all', @testCollision) # include @draw event!!!
    @collisionUtil = new CollisionUtil
    @currentBox = new Box
    @availableNewBoxId = 1
    @flash = "Initialized completed!"

  updateCollisionStatus:(options) ->
    @collisionUtil.updateRelation(options)

  testCollisionBetween: (boxA, boxB) ->
    @collisionUtil.testCollisionBetween(boxA, boxB)
  addNewBox: =>
    newBox  = new Box
    newBox.setXPosition(newBox.getXPosition() + @availableNewBoxId * 4 )
    newBox.setYPosition(newBox.getYPosition() + @availableNewBoxId * 4 )
    newBox.setTitleName(@availableNewBoxId)
    newBox.set('boxId', @availableNewBoxId)
    newBox.box().on "click", =>
      Logger.debug "box#{newBox.getTitleName()} clicked!"
      @flash =  "box#{newBox.getTitleName()} selected!"
      @updateCurrentBox(newBox)

    @add(newBox)
    @updateCurrentBox(newBox)
    @availableNewBoxId += 1

    @testCollision()
    Logger.debug("@availableNewBoxId:\t" + @availableNewBoxId)
  removeCurrentBox: =>
    if @length == 0
      @flash = 'There is no box.'
    else
      @currentBox.get('group').destroy()
      @remove(@currentBox)
      @currentBox = @last()
    if @length == 0
      @flash = 'There is no box.'
    @showCurrentBoxPanel()
    Logger.debug("remove button clicked!")
  testCollision:()->
    Logger.debug("...Collision start...")
    result =_.reduce(@models,
                    ((status, box) ->
                      if @currentBox.getTitleName() != box.getTitleName() && @currentBox.getTitleName() != 'nullID'
                        @testCollisionBetween(@currentBox, box) || status
                      else
                        status), 
                    false, this)
    Logger.debug("...Collision result: #{result}")
    @draw()
  draw: () ->
    for box in @models
      Logger.debug("In draw: Box#{box.getTitleName()}.color=#{box.get('rect').getFill()}")
      @layer.add(box.box())
    @layer.draw()

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
    unless @validateZone(@currentBox)
      @currentBox.setYPosition(@currentBox.getYPosition() + 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved UP!"
    @testCollision()
    @updateCurrentBox()
  down: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setYPosition(@currentBox.getYPosition() + 4)
    unless @validateZone(@currentBox)
      @currentBox.setYPosition(@currentBox.getYPosition() - 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved DOWN!"
    @testCollision()
    @updateCurrentBox()
  left: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setXPosition(@currentBox.getXPosition() - 4)
    unless @validateZone(@currentBox)
      @currentBox.setXPosition(@currentBox.getXPosition() + 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved LEFT!"
    @testCollision()
    @updateCurrentBox()
  right: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    Logger.debug("@currentBox:\t" + @currentBox.getXPosition())
    @currentBox.setXPosition(@currentBox.getXPosition() + 4)
    unless @validateZone(@currentBox)
      @currentBox.setXPosition(@currentBox.getXPosition() - 4)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved RIGHT!"
    @testCollision()
    @updateCurrentBox()
  validateZone: (box) ->
    result = _.reduce([box.getPointA(),box.getPointB(),box.getPointC(),box.getPointD()], 
                ((status, point) ->
                  status && @validateZoneX(point) && @validateZoneY(point)), 
                  true, this)
    Logger.debug("validresult:\t #{result}")
    result
  validateZoneX: (point) ->
    Logger.debug("validateZoneX: point.x #{point.x}, @zone.x #{@zone.x}")
    0<= point.x <= @zone.x
  validateZoneY: (point) ->
    Logger.debug("validateZoneY: point.y #{point.y}, @zone.x #{@zone.y}")
    0<= point.y <= @zone.y


class CollisionPair extends Backbone.Model
  ## attributes:
  ##  boxId
  ##  RelationCollection
  ##
  ## Like:
  ## {boxId :  1, relations: [{boxId : 2, status : false}, {boxId : 3, status : true}]}

  ## class RelationCollection ##
  class Relation extends Backbone.Model
    defaults: {
      status: false
    }
    initialize: (boxId) ->
      @set boxId: boxId
    pprint: () ->
      "#{@get('boxId')} #{@get('status')}"
  class RelationCollection extends Backbone.Collection
    model: Relation
    # attr: boxId
    pprint: () ->
      _.reduce @models, ((str, aRelation) ->
        "#{str} | #{aRelation.pprint()}"), ""
    findRelationWith:(boxId) ->
      aRelation = _.find @models, (aRelation) ->
          aRelation.get('boxId') == boxId
      if aRelation == undefined
        aRelation = new Relation(boxId)
        @add(aRelation)
      aRelation
  ##############################
  initialize:(boxId) ->
    @boxId = boxId
  findRelationWith:(boxId) ->
    @get('relations').findRelationWith(boxId)
  pprint:() ->
      "box#{@boxId} #{@get('relations').pprint()}"

  isRelationEmpty: ->
    (@get('relations') == undefined)
    
  isCollisionWith: (boxId) ->
    if @isRelationEmpty()
      @makeUnCollisionRelationWith(boxId) 
    @findRelationWith(boxId).get('status') 

  makeCollisionRelationWith:(boxId) ->
    if @get('boxId') == boxId
      return
    if @isRelationEmpty()
      @set relations: new RelationCollection
      relations = @get('relations')
      relations.add(new Relation(boxId)) 
    else
      relations = @get('relations')
      relations.findRelationWith(boxId).set('status', true) 
    return
  makeUnCollisionRelationWith:(boxId) ->
    if @get('boxId') == boxId
      return
    if @isRelationEmpty()
      @set relations: new RelationCollection
      relations = @get('relations')
      relations.add(new Relation(boxId))      
    else
      relations = @get('relations')
      relations.findRelationWith(boxId).set('status', false) 
    return    

class CollisionUtil extends Backbone.Collection
  model: CollisionPair

  initialize: ->
    # @on("change", @pprint)

  pprint: () ->
    _.each(@models, (pair) ->
      Logger.dev "pair.#{pair.pprint()}")
  findPair:(boxId) ->
    aPair = _.find @models, (pair) ->
          pair.boxId == boxId
    # if aPair == undefined
    #   aPair = new CollisionPair(boxId: boxId)
    #   @add(aPair)
    aPair
  removeCollisionPair:(boxA, boxB) ->
    Logger.dev("removeCollisionPair: box#{boxA.getTitleName()}, box#{boxB.getTitleName()}")
    @updateCollisionRelationBetween(action: 'remove', boxAId: boxA.getTitleName(), boxBId: boxB.getTitleName())
    Logger.dev("@isCollisionInclude(boxA) #{@isCollisionInclude(boxA)}  isCollisionInclude(boxB) #{ @isCollisionInclude(boxB)}")
    unless @isCollisionInclude(boxA)
      boxA.makeUnCollisionStatus()
    unless @isCollisionInclude(boxB)
      boxB.makeUnCollisionStatus()

  addCollisionPair:(boxA, boxB) ->
    Logger.dev("addCollisionPair: box#{boxA.getTitleName()}, box#{boxB.getTitleName()}")
    @updateCollisionRelationBetween(action: 'add', boxAId: boxA.getTitleName(), boxBId: boxB.getTitleName())
    boxA.makeCollisionStatus()
    boxB.makeCollisionStatus()

  updateCollisionRelationBetween:(options) ->
  ##options
  ##action: add,         boxAId: boxA, boxBId: boxB, collisionStatus: status
  ##action: remove,      boxAId: boxA, boxBId: boxB, collisionStatus: status
  ##action: changeID,    boxAId: boxA, boxBId: boxB
    boxAId = options.boxAId
    boxBId = options.boxBId
    if options.action == 'add'
      boxAPair = @findPair(boxAId)
      boxBPair = @findPair(boxBId)
      if boxAPair == undefined
        boxAPair = new CollisionPair(boxAId)
        @add(boxAPair)
      if boxBPair == undefined
        boxBPair = new CollisionPair(boxBId)
        @add(boxBPair)
      Logger.dev("CollisionUtil:\t add box | box#{boxAPair.boxId} |box#{boxBPair.boxId}")
      boxAPair.makeCollisionRelationWith(boxBId)
      boxBPair.makeCollisionRelationWith(boxAId)

    else if options.action == 'remove'
      boxAPair = @findPair(boxAId)
      boxBPair = @findPair(boxBId)
      if boxAPair == undefined
        boxAPair = new CollisionPair(boxAId)
        @add(boxAPair)
      if boxBPair == undefined
        boxBPair = new CollisionPair(boxBId)
        @add(boxBPair)
      Logger.dev("CollisionUtil:\t remove box | box#{boxAPair.boxId} |box#{boxBPair.boxId}")
      boxAPair.makeUnCollisionRelationWith(boxBId)
      boxBPair.makeUnCollisionRelationWith(boxAId)

    else if options.action == 'changeID'
      Logger.dev("CollisionUtil:\t changeID box")

    Logger.dev("boxAPair Relation: #{boxAPair.pprint()}")
    Logger.dev("boxBPair Relation: #{boxBPair.pprint()}")
  isCollisionInclude:(boxA) ->
    boxAId = boxA.getTitleName()
    result= _.filter @models, (pair) ->
        pair.get('boxId') != boxAId && pair.isCollisionWith(boxAId)
    status  = (result.length > 0)


  ######## public api ########
  testCollisionBetween:(boxA,boxB) ->
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
    Logger.dev("testCollisionBetween: box#{boxA.getTitleName()} box#{boxB.getTitleName()} #{status}")
    if status
      @addCollisionPair(boxA, boxB)
    else
      @removeCollisionPair(boxA, boxB)
    status

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
@board = new StackBoard


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



