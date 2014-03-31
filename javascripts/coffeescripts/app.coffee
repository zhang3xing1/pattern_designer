# "use strict"
###### rivets adapter configure, below ######
rivets.adapters[":"] =
  subscribe: (obj, keypath, callback) ->
    # console.log("1.subscribe:\t #{obj} ||\t #{keypath}")
    obj.on "change:" + keypath, callback
    return

  unsubscribe: (obj, keypath, callback) ->
    # console.log("2.unsubscribe:\t #{obj} ||\t #{keypath}")
    obj.off "change:" + keypath, callback
    return

  read: (obj, keypath) ->
    # console.log("3.read:\t\t\t #{obj} ||\t #{keypath}")
    # if((obj.get keypath) == undefined)
    #   console.log("3.read:++ #{obj[keypath]()} \t #{(obj.get keypath)}")
    #   obj[keypath]()
    # else
    #   obj.get keypath
    obj.get keypath

  publish: (obj, keypath, value) ->
    # console.log("4.publish:\t\t #{obj} ||\t #{keypath}")
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
    boxId:            'nullID'
    collisionStatus:  false
    moveOffset:       4
    rotate:           0
  }
  initialize: (params) ->
    @on('change:rect', @rectChanged)
    #Fill Color: rgb(60, 118, 61)

    @set innerBox: {x: params.x, y: params.y, width: params.width, height: params.height}

    @set rect: new Kinetic.Rect(
                                  x:            0
                                  y:            0
                                  width:        @get('innerBox').width
                                  height:       @get('innerBox').height
                                )
    @set title: new Kinetic.Text(
                                  x:            @get('rect').x() + @get('rect').width()/2  - 5
                                  y:            @get('rect').y() + @get('rect').height()/2 + 5
                                  fontSize:     14
                                  fontFamily:   "Calibri"
                                  fill:         "white"
                                  text:         @get('boxId')
                                  scaleY:       -1
                                )
    @set group: new Kinetic.Group(
                                  x: 0
                                  y: 0
                                )
    @get('group').add(@get('rect'))
    @get('group').add(@get('title'))

    ###### Box has an outer Rect ######
    if params.minDistance > 0
      @set minDistance: params.minDistance
      @set outerBox: {x: @get('innerBox').x - params.minDistance, \
                      y: @get('innerBox').y - params.minDistance,  \
                      width: @get('innerBox').width + 2 * params.minDistance, \
                      height: @get('innerBox').height + 2 * params.minDistance}
      @set outerRect: new Kinetic.Rect(
                              x:              @get('outerBox').x
                              y:              @get('outerBox').y
                              width:          @get('outerBox').width
                              height:         @get('outerBox').height
                              strokeRed:      38
                              strokeGreen:    49
                              strokeBlue:     9
                              strokeAlpha:    0.5
                            )
      @get('outerRect').dash(([4, 5]))
      @get('group').add(@get('outerRect'))
    Logger.debug('Box: Generate a new box.')

  hasOuterRect: () ->
    @get('minDistance') > 0
  getBoxId: () ->
    @get('boxId') 
  getMoveOffset: () ->
    offset = Number($("#ex8").val()) % 99
    if offset % 99 > 0
      @set('moveOffset', offset % 99)
      offset % 99
    else
      4
  setTitleName: (newTitle) ->
    @get('title').setText(newTitle) 
  getTitleName: () ->
    @get('title').text() 
  setXPosition: (x) ->
    @get('group').setX(x)
  getXPosition: (options={innerOrOuter: 'inner'}) ->
    if options.innerOrOuter == 'outer'
      @get('group').x() - @get('minDistance')
    else
      @get('group').x()
  setYPosition: (y) ->
    @get('group').setY(y)
  getYPosition: (options={innerOrOuter: 'inner'})  ->
    if options.innerOrOuter == 'outer'
      @get('group').y() - @get('minDistance')
    else    
      @get('group').y()
  setHeight: (height) ->
    @get('rect').setHeight(height)
  getHeight:(options={innerOrOuter: 'inner'}) ->
    if options.innerOrOuter == 'outer'
      @get('rect').height() + @get('minDistance') * 2
    else    
      @get('rect').height()
  setWidth: (width) ->
    @get('rect').setWidth(width)
  getWidth: (options={innerOrOuter: 'inner'}) ->
    if options.innerOrOuter == 'outer'
      @get('rect').width() + @get('minDistance') * 2
    else  
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
  # updateRectStyle: (options) ->
  #   Logger.debug("updateRectStyle: #{@getTitleName()}")
  #   @get('rect').setFill(options.color)
  updateTitle: (newTitle) ->
    @get('title').setText(newTitle)

  rectChanged:() ->
    Logger.debug('box model changed by rect.')
  box: ->
    @get('group')
  makeCollisionStatus: ->
    Logger.dev("box#{@getTitleName()}: makeCollisionStatus")
    @set('collisionStatus', true)
  makeUnCollisionStatus: ->
    Logger.dev("box#{@getTitleName()}: makeUnCollisionStatus")
    @set('collisionStatus', false)
  changeFillColor: ->
    if @get('collisionStatus')
      @get('rect').fillRed(82)
      @get('rect').fillGreen(1)
      @get('rect').fillBlue(246)
    else
      @get('rect').fillRed(82)
      @get('rect').fillGreen(221)
      @get('rect').fillBlue(246)

  printPoints: ->
    Logger.debug("PointA(x:#{@getPointA().x},y:#{@getPointA().y}) " +
                "PointB(x:#{@getPointB().x},y:#{@getPointB().y}) " +
                "PointC(x:#{@getPointC().x},y:#{@getPointC().y}) " +
                "PointD(x:#{@getPointD().x},y:#{@getPointD().y}) ")


class @Boxes extends Backbone.Collection
  model: Box
  initialize: (params)->
    @layer = params.layer
    @zone = params.zone
    @box_params = params.box

    @on('add', @showCurrentBoxPanel)
    @on('all', @draw) 
    @collisionUtil = new CollisionUtil
    @currentBox = new Box(@box_params)
    @availableNewBoxId = 1
    @flash = "Initialized completed!"

  pprint: () ->
    _.reduce(@models,((str,box) ->
       "#{str} box#{box.getBoxId()}"
      ),"")
  updateCollisionStatus:(options) ->
    @collisionUtil.updateRelation(options)

  deleteCollisionWith:(box = @currentBox) ->
    @collisionUtil.deleteCollisionWith(box, @models)

  testCollisionBetween: (boxA, boxB) ->
    @collisionUtil.testCollisionBetween(boxA, boxB, {collisionType: 'outer-outer'})
  addNewBox: =>
    newBox  = new Box(@box_params)
    newBox.setXPosition(Math.min(newBox.getXPosition() + @availableNewBoxId * newBox.getMoveOffset(), @zone.width - newBox.getWidth() ))
    newBox.setYPosition(Math.min(newBox.getYPosition() + @availableNewBoxId * newBox.getMoveOffset(), @zone.height - newBox.getHeight()))
    newBox.setTitleName(@availableNewBoxId)
    newBox.set('boxId', @availableNewBoxId)
    # alert(newBox.get('boxId'))
    newBox.box().on "click", =>
      Logger.debug "box#{newBox.getTitleName()} clicked!"
      @flash =  "box#{newBox.getTitleName()} selected!"
      @updateCurrentBox(newBox)

    @add(newBox)
    @updateCurrentBox(newBox)
    @flash =  "box#{@currentBox.getTitleName()} selected!"
    @availableNewBoxId += 1

    @testCollision()
  removeCurrentBox: =>
    if @length == 0
      @flash = 'There is no box.'
    else
      @deleteCollisionWith()
      @currentBox.get('group').destroy()
      @remove(@currentBox)
      if @length == 0
        @currentBox = new Box(@box_params) # for alert from rivetsjs
        @flash = 'There is no box.'
      else
        @currentBox = @last()
    @draw()
    @showCurrentBoxPanel()
    @flash =  "box#{@currentBox.getTitleName()} selected!"
    Logger.dev("remove button clicked!")
  testCollision:()->
    Logger.debug("...Collision start...")
    result = false
    # _.each(@models, ((box) ->
    #     if @currentBox.getTitleName() != box.getTitleName() && @currentBox.getTitleName() != 'nullID'
    #        result = result || @testCollisionBetween(@currentBox, box)  
    #   ), this)
    result =_.reduce(@models,
                    ((status, box) ->
                      if @currentBox.getBoxId() != box.getBoxId() && @currentBox.getBoxId() != 'nullID'
                        @testCollisionBetween(@currentBox, box) || status
                      else
                        status), 
                    false, this)
    result
    Logger.debug("...Collision result: #{result}")
    @draw()
  draw: () ->
    index = 0
    while index < @models.length
      box = @models[index]
      Logger.dev("In draw: Box#{box.getTitleName()}.collision=#{box.get('collisionStatus')}")
      box.changeFillColor()
      box.updateTitle(index + 1) # keep box name as number sequence.
      @layer.add(box.box())
      index += 1
    @layer.draw()

  updateCurrentBox: (newBox = @currentBox) ->
    @currentBox = newBox
    rivets.bind $('.box'),{box: newBox}
  showCurrentBoxPanel: () ->
    rivets.bind $('.box'),{box: @currentBox}
    Logger.dev("showCurrentBoxPanel: Box number: #{@length}; ")
    Logger.dev("In Boxes: #{@pprint()}; ")
    @pprint()
    if(@length == 0)
      $('.panel').css('display','none')
    else
      $('.panel').css('display','block')
  up: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setYPosition(@currentBox.getYPosition() - @currentBox.getMoveOffset())
    unless @validateZone(@currentBox)
      @currentBox.setYPosition(0)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved UP!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
    @testCollision()
    @updateCurrentBox()
  down: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setYPosition(@currentBox.getYPosition() + @currentBox.getMoveOffset())
    unless @validateZone(@currentBox)
      @currentBox.setYPosition(@zone.height - @currentBox.getHeight())
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved DOWN!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
    @testCollision()
    @updateCurrentBox()
  left: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setXPosition(@currentBox.getXPosition() - @currentBox.getMoveOffset())
    unless @validateZone(@currentBox)
      @currentBox.setXPosition(0)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved LEFT!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
    @testCollision()
    @updateCurrentBox()
  right: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    Logger.debug("@currentBox:\t" + @currentBox.getXPosition())
    @currentBox.setXPosition(@currentBox.getXPosition() + @currentBox.getMoveOffset())
    unless @validateZone(@currentBox)
      @currentBox.setXPosition(@zone.width - @currentBox.getWidth())
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved RIGHT!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
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
    Logger.debug("validateZoneX: point.x #{point.x}, @zone.width #{@zone.width}")
    0<= point.x <= @zone.width
  validateZoneY: (point) ->
    Logger.debug("validateZoneY: point.y #{point.y}, @zone.width #{@zone.height}")
    0<= point.y <= @zone.height


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
      relations.findRelationWith(boxId).set('status', true) 
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
  makeUnCollisionRelationAll: () ->
    relations = @get('relations')
    if relations != undefined 
      _.each(relations.models,((aRelation) ->
        aRelation.set('status', false)
        Logger.dev "In makeUnCollisionRelationAll: Pair#{this.boxId}, withBox#{aRelation.get('boxId')} #{aRelation.get('status')}"
        ),this)
class CollisionUtil extends Backbone.Collection
  model: CollisionPair

  initialize: ->
    # @on("change", @pprint)

  pprint: () ->
    _.each(@models, (pair) ->
      Logger.dev "In CollisionUtil: pair.#{pair.pprint()}")
  findPair:(boxId) ->
    aPair = _.find @models, (pair) ->
          pair.boxId == boxId
    # if aPair == undefined
    #   aPair = new CollisionPair(boxId: boxId)
    #   @add(aPair)
    aPair
  removeCollisionPair:(boxA, boxB) ->
    Logger.dev("removeCollisionPair: box#{boxA.getBoxId()}, box#{boxB.getBoxId()}")
    @updateCollisionRelationBetween(action: 'remove', boxAId: boxA.getBoxId(), boxBId: boxB.getBoxId())
    Logger.dev("@isCollisionInclude(boxA) #{@isCollisionInclude(boxA)}  isCollisionInclude(boxB) #{ @isCollisionInclude(boxB)}")
    unless @isCollisionInclude(boxA)
      boxA.makeUnCollisionStatus()
    unless @isCollisionInclude(boxB)
      boxB.makeUnCollisionStatus()

  addCollisionPair:(boxA, boxB) ->
    Logger.dev("addCollisionPair: box#{boxA.getBoxId()}, box#{boxB.getBoxId()}")
    @updateCollisionRelationBetween(action: 'add', boxAId: boxA.getBoxId(), boxBId: boxB.getBoxId())
    boxA.makeCollisionStatus()
    boxB.makeCollisionStatus()

  deleteCollisionWith:(box, boxes) ->
    toDeletedBoxId = box.getBoxId()
    @updateCollisionRelationBetween(action: 'delete', boxId: toDeletedBoxId)
    _.each(boxes, ((aBox) ->
      if @isCollisionInclude(aBox)
        aBox.makeCollisionStatus()
      else
        aBox.makeUnCollisionStatus()), this)
  updateCollisionRelationBetween:(options) ->
  ##options
  ##action: add,         boxAId: boxA, boxBId: boxB, collisionStatus: status
  ##action: remove,      boxAId: boxA, boxBId: boxB, collisionStatus: status
  ##action: changeID,    boxAId: boxA, boxBId: boxB
    boxAId = options.boxAId
    boxBId = options.boxBId
    toDeletedBoxId  = options.boxId
    if options.action == 'add'
      boxAPair = @findPair(boxAId)
      boxBPair = @findPair(boxBId)
      if boxAPair == undefined
        boxAPair = new CollisionPair(boxAId)
        @add(boxAPair)
      if boxBPair == undefined
        boxBPair = new CollisionPair(boxBId)
        @add(boxBPair)
      Logger.dev("CollisionUtil:\t addPair:  box#{boxAPair.boxId} box#{boxBPair.boxId}")
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
      Logger.dev("CollisionUtil:\t removePair:  box#{boxAPair.boxId} box#{boxBPair.boxId}")
      boxAPair.makeUnCollisionRelationWith(boxBId)
      boxBPair.makeUnCollisionRelationWith(boxAId)
    else if options.action == 'delete'
      toDeletedBoxPair = @findPair(toDeletedBoxId)
      _.each(@models, ((pair) ->
          if pair.boxId == toDeletedBoxId
            @remove(toDeletedBoxPair)
            # toDeletedBoxPair.makeUnCollisionRelationAll()
          else 
            pair.makeUnCollisionRelationWith(toDeletedBoxId)

          Logger.dev("In delete: toDeletedBoxId: #{toDeletedBoxId}")
          Logger.dev("In delete: pair Relation: #{pair.pprint()}")
          Logger.dev("In delete: toDeletedBoxPair Relation: #{toDeletedBoxPair.pprint()}")
        ),this)
    else if options.action == 'changeID'
      Logger.dev("CollisionUtil:\t changeID box")
    Logger.dev("---->Show pair status: ")
    @pprint()
    Logger.dev("<----Show pair status: ")
  isCollisionInclude:(boxA) ->
    boxAId = boxA.getBoxId()
    result= _.filter @models, (pair) ->
        pair.boxId != boxAId && pair.isCollisionWith(boxAId)
    status  = (result.length > 0)


  ######## public api ########
  testCollisionBetween:(boxA,boxB,options = {collisionType: 'inner-inner'}) ->
    status  =     false
    if options.collisionType == 'inner-inner'
      boxATop =     boxA.getYPosition()
      boxABottom =  boxA.getYPosition() + boxA.getHeight()
      boxALeft   =  boxA.getXPosition()
      boxARight  =  boxA.getXPosition() + boxA.getWidth()
      boxBTop    =  boxB.getYPosition()
      boxBBottom =  boxB.getYPosition() + boxB.getHeight()
      boxBLeft   =  boxB.getXPosition()
      boxBRight  =  boxB.getXPosition() + boxB.getWidth()
    else if options.collisionType == 'outer-outer'
      if boxA.hasOuterRect
        boxATop =     boxA.getYPosition({innerOrOuter: 'outer'})
        boxABottom =  boxA.getYPosition({innerOrOuter: 'outer'}) + boxA.getHeight({innerOrOuter: 'outer'})
        boxALeft   =  boxA.getXPosition({innerOrOuter: 'outer'})
        boxARight  =  boxA.getXPosition({innerOrOuter: 'outer'}) + boxA.getWidth({innerOrOuter: 'outer'})
        boxBTop    =  boxB.getYPosition()
        boxBBottom =  boxB.getYPosition() + boxB.getHeight()
        boxBLeft   =  boxB.getXPosition()
        boxBRight  =  boxB.getXPosition() + boxB.getWidth()
      else
        boxATop =     boxA.getYPosition()
        boxABottom =  boxA.getYPosition() + boxA.getHeight()
        boxALeft   =  boxA.getXPosition()
        boxARight  =  boxA.getXPosition() + boxA.getWidth()
        boxBTop    =  boxB.getYPosition({innerOrOuter: 'outer'})
        boxBBottom =  boxB.getYPosition({innerOrOuter: 'outer'}) + boxB.getHeight({innerOrOuter: 'outer'})
        boxBLeft   =  boxB.getXPosition({innerOrOuter: 'outer'})
        boxBRight  =  boxB.getXPosition({innerOrOuter: 'outer'}) + boxB.getWidth({innerOrOuter: 'outer'})
    
    status = true  unless boxABottom < boxBTop or boxATop > boxBBottom or boxALeft > boxBRight or boxARight < boxBLeft
    Logger.dev("testCollisionBetween: box#{boxA.getBoxId()} box#{boxB.getBoxId()} #{status}")     
    if status
      @addCollisionPair(boxA, boxB)
    else
      @removeCollisionPair(boxA, boxB)
    status

class @StackBoard
  constructor:(params) ->
    @zone = params.zone
    #background_color: rgb(255,​ 228,​ 196)
    
    longerEdge = Math.max(pallet.width, pallet.height)
    shorterEdge = Math.min(pallet.width, pallet.height)
    margin = Math.max(pallet.overhang, box.minDistance)
    overhangOffset = {x: 0 , y: 0, edge: margin}

    if box.minDistance > pallet.overhang  
      overhangOffset.x = overhangOffset.y = box.minDistance - pallet.overhang
      overhangOffset.edge = pallet.overhang - box.minDistance

    @ratio = @zone.height / (longerEdge + 2 * margin)

    stageBackground = new Kinetic.Rect(
        x:            0
        y:            0
        width:        @zone.width
        height:       @zone.height
        fill:         'white'
      )
    palletBackground = new Kinetic.Rect(
        x:            margin * @ratio
        y:            margin * @ratio
        width:        shorterEdge * @ratio
        height:       longerEdge * @ratio
        fillRed:      251
        fillGreen:    209
        fillBlue:     175
      )
    overhangBackground = new Kinetic.Rect(
        x:            overhangOffset.x * @ratio
        y:            overhangOffset.y * @ratio
        width:        (shorterEdge + pallet.overhang * 2) * @ratio 
        height:       (longerEdge + pallet.overhang * 2) * @ratio
        strokeRed:      238
        strokeGreen:    49
        strokeBlue:     109
        strokeAlpha:    0.5
      )

    overhangBackground.dash(([4, 5]))

    @stage = new Kinetic.Stage(
      container: "canvas_container"
      width:  @zone.width * @zone.stage_zoom
      height: @zone.height * @zone.stage_zoom
    )

    @layer = new Kinetic.Layer()
    @stage.add @layer

    @layer.add stageBackground
    @layer.add palletBackground
    @layer.add overhangBackground
    # @layer.getContext().translate(0, @zone.height)
    # @layer.getContext().scale(1, -1);


    Logger.debug("StackBoard: Stage Initialized!")
    Logger.info("StackBoard: Initialized!")
    boxes_params = {layer: @layer, zone: @zone, box: params.box}
    @boxes = new Boxes(boxes_params)
    @boxes.shift()
    rivets.bind $('.boxes'),{boxes: @boxes}
  calculateOriginPoint:() ->

#### Params ####

# unit: cm
pallet =      {width:250, height:400, overhang: -10}  
box    =      {x:0, y: 0, width:60,  height:30,  minDistance: 5}
# unit: pixal
# canvas available paiting zone
canvasZone =  {width:260, height:320, stage_zoom: 1.5}

params = {pallet: pallet, box: box, zone: canvasZone}

################


@board = new StackBoard(params)

rivets.formatters.offset = (value) ->
   value = value % 99 

$("input").prop "readonly", true
$(".offset").prop "readonly", false

$("#ex8").slider()

$("#ex8").on "slide", (slideEvt) ->
  $("#box-move-offset").val($("#ex8").val())
  return


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



