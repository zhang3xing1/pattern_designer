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
  statuses = ['dev']
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
      console.log(instance.debug(message))

class @Box extends Backbone.Model
  defaults: {
    boxId:            '0'
    collisionStatus:  false
    settledStatus:    false   # false: unsettled | true: settled(placed)
    moveOffset:       4
    rotate:           0   
    crossZoneLeft:    false
    crossZoneRight:   false
    crossZoneTop:     false
    crossZoneBottom:  false

  }
  initialize: (params) ->
    @on('change:rect', @rectChanged)
    #Fill Color: rgb(60, 118, 61)
    
    [box_params, @color_params, @ratio, @zone] = [params.box, params.color, params.ratio, params.zone]

    @set ratio: params.ratio

    @set innerBox: 
      x:      box_params.x 
      y:      box_params.y
      width:  box_params.width
      height: box_params.height

    @set rect: new Kinetic.Rect(
                                  x:            0
                                  y:            0
                                  width:        @get('innerBox').width
                                  height:       @get('innerBox').height
                                )
    @set title: new Kinetic.Text(
                                  x:            @get('rect').x() + @get('rect').width()/2  - 5
                                  y:            @get('rect').y() + @get('rect').height()/2 - 5
                                  fontSize:     14
                                  fontFamily:   "Calibri"
                                  fill:         "white"
                                  text:         @get('boxId')
                                  # scaleX:       -1
                                )
    @set group: new Kinetic.Group(
                                  x: 0
                                  y: 0
                                )
    @get('rect').dash(([4, 5]))
    @get('group').add(@get('rect'))
    @get('group').add(@get('title'))

    ###### Box has an outer Rect ######
    # box_params.minDistance = $("input:checked","#minDistanceRadio").val()
    @set outerBox: 
      x:      @get('innerBox').x - box_params.minDistance
      y:      @get('innerBox').y - box_params.minDistance
      width:  @get('innerBox').width + 2 * box_params.minDistance
      height: @get('innerBox').height + 2 * box_params.minDistance
    if box_params.minDistance > 0
      @set minDistance: box_params.minDistance
      @set outerRect: new Kinetic.Rect(
                              x:              @get('outerBox').x
                              y:              @get('outerBox').y
                              width:          @get('outerBox').width
                              height:         @get('outerBox').height
                            )
      @get('outerRect').dash(([4, 5]))
      @get('group').add(@get('outerRect'))
    else
      @set outerRect: new Kinetic.Rect(
                              x:              @get('outerBox').x
                              y:              @get('outerBox').y
                              width:          @get('outerBox').width
                              height:         @get('outerBox').height
                              fillAlpha:      0
                            )

    Logger.debug('Box: Generate a new box.')

  hasOuterRect: () ->
    @get('minDistance') > 0
  getBoxId: () ->
    @get('boxId') 
  getMoveOffset: () ->
    Logger.debug "getMoveOffset #{@get('moveOffset')}"
    # moveoffset * ratio = unit mm, not unit px
    Number(@get('moveOffset') * @ratio)


  setTitleName: (newTitle) ->
    @get('title').setText(newTitle) 
  getTitleName: () ->
    @get('title').text() 
  setXPosition: (x) ->
    @get('group').setX(x)
  getXPositionByRatio: () ->
    (@get('group').x() - @zone.bound.left) / @ratio
  getYPositionByRatio: ()  ->   
    (@zone.bound.bottom - @get('group').y() - @getHeight()) / @ratio
  getWidthByRatio: () ->
    @get('rect').width() / @ratio
  getHeightByRatio: ()  ->   
    @get('rect').height() / @ratio

  getXPosition: (options={innerOrOuter: 'inner'}) ->
    if options.innerOrOuter == 'outer' && @hasOuterRect()
      @get('group').x() - @get('minDistance')
    else
      @get('group').x()
  setYPosition: (y) ->
    @get('group').setY(y)
  getYPosition: (options={innerOrOuter: 'inner'})  ->
    if options.innerOrOuter == 'outer' && @hasOuterRect()
      @get('group').y() - @get('minDistance')
    else    
      @get('group').y()
  setHeight: (height) ->
    @get('rect').setHeight(height)
  getHeight:(options={innerOrOuter: 'inner'}) ->
    if options.innerOrOuter == 'outer' && @hasOuterRect()
      @get('rect').height() + @get('minDistance') * 2
    else    
      @get('rect').height()
  setWidth: (width) ->
    @get('rect').setWidth(width)
  getWidth: (options={innerOrOuter: 'inner'}) ->
    if options.innerOrOuter == 'outer' && @hasOuterRect()
      @get('rect').width() + @get('minDistance') * 2
    else  
      @get('rect').width()
  getPointA: () ->
    pointX = 
      x: @getXPosition()
      y: @getYPosition()
      flag: 'A'
  getPointB: () ->
    pointB = 
      x: @getXPosition() + @get('rect').getWidth()
      y: @getYPosition()
      flag: 'B'
  getPointC: () ->
    Logger.debug "@getYPosition() #{@getYPosition()}, @get('rect').getHeight(): #{@get('rect').getHeight()}"
    pointC = 
      x: @getXPosition()
      y: @getYPosition() + @get('rect').getHeight()
      flag: 'C'
  getPointD: () ->
    pointC = 
      x: @getXPosition() + @get('rect').getWidth()
      y: @getYPosition() + @get('rect').getHeight()
      flag: 'D'
  updateTitle: (newTitle) ->
    @get('title').setText(newTitle)
  rectChanged:() ->
    Logger.debug('box model changed by rect.')
  box: ->
    @get('group')
  makeCollisionStatus: ->
    Logger.debug("box#{@getTitleName()}: makeCollisionStatus")
    @set('collisionStatus', true)
  makeUnCollisionStatus: ->
    Logger.debug("box#{@getTitleName()}: makeUnCollisionStatus")
    @set('collisionStatus', false)

  rotateWithAngle: (angle) ->
    newRotateAngle = (@get('rotate') + angle) / 360 
    oldBoxFrame = 
      innerWidth:    @get('rect').getWidth()
      innerHeight:   @get('rect').getHeight()
      outerWidth:    @get('outerRect').getWidth()
      outerHeight:   @get('outerRect').getHeight()     
    @get('rect').setWidth(oldBoxFrame.innerHeight)
    @get('rect').setHeight(oldBoxFrame.innerWidth)
    @get('outerRect').setWidth(oldBoxFrame.outerHeight)
    @get('outerRect').setHeight(oldBoxFrame.outerWidth)
    @get('title').setX(@get('rect').x() + @get('rect').width()/2  - 5)
    @get('title').setY(@get('rect').y() + @get('rect').height()/2 - 5)
    @set('rotate',(@get('rotate') + angle) % 180)

    Logger.debug "[rotateWithAngle] width: #{@get('rect').getWidth()}, height: #{@get('rect').getHeight()}"

  changeFillColor: ->
    Logger.debug "Box#{@getTitleName()} collisionStatus: #{@get('collisionStatus')}\t settledStatus: #{@get('settledStatus')}"
    if @get('settledStatus') 
      @get('rect').fillRed(           @color_params.boxPlaced.inner.red)
      @get('rect').fillGreen(         @color_params.boxPlaced.inner.green)
      @get('rect').fillBlue(          @color_params.boxPlaced.inner.blue)
      @get('rect').fillAlpha(         @color_params.boxPlaced.inner.alpha)
      @get('rect').strokeRed(         @color_params.boxPlaced.inner.stroke.red)
      @get('rect').strokeGreen(       @color_params.boxPlaced.inner.stroke.green)
      @get('rect').strokeBlue(        @color_params.boxPlaced.inner.stroke.blue)
      @get('rect').strokeAlpha(       @color_params.boxPlaced.inner.stroke.alpha)
      if @hasOuterRect()
        @get('outerRect').fillRed(      @color_params.boxPlaced.outer.red)
        @get('outerRect').fillGreen(    @color_params.boxPlaced.outer.green)
        @get('outerRect').fillBlue(     @color_params.boxPlaced.outer.blue)
        @get('outerRect').fillAlpha(    @color_params.boxPlaced.outer.alpha)
        @get('outerRect').strokeRed(    @color_params.boxPlaced.outer.stroke.red)
        @get('outerRect').strokeGreen(  @color_params.boxPlaced.outer.stroke.green)
        @get('outerRect').strokeBlue(   @color_params.boxPlaced.outer.stroke.blue)
        @get('outerRect').strokeAlpha(  @color_params.boxPlaced.outer.stroke.alpha)
    else
      if @get('collisionStatus')
        @get('rect').fillRed(           @color_params.boxSelected.collision.inner.red)
        @get('rect').fillGreen(         @color_params.boxSelected.collision.inner.green)
        @get('rect').fillBlue(          @color_params.boxSelected.collision.inner.blue)
        @get('rect').fillAlpha(         @color_params.boxSelected.collision.inner.alpha)
        @get('rect').strokeRed(         @color_params.boxSelected.collision.inner.stroke.red)
        @get('rect').strokeGreen(       @color_params.boxSelected.collision.inner.stroke.green)
        @get('rect').strokeBlue(        @color_params.boxSelected.collision.inner.stroke.blue)
        @get('rect').strokeAlpha(       @color_params.boxSelected.collision.inner.stroke.alpha)
        @get('outerRect').fillRed(      @color_params.boxSelected.collision.outer.red)
        if @hasOuterRect()
          @get('outerRect').fillGreen(    @color_params.boxSelected.collision.outer.green)
          @get('outerRect').fillBlue(     @color_params.boxSelected.collision.outer.blue)
          @get('outerRect').fillAlpha(    @color_params.boxSelected.collision.outer.alpha)
          @get('outerRect').strokeRed(    @color_params.boxSelected.collision.outer.stroke.red)
          @get('outerRect').strokeGreen(  @color_params.boxSelected.collision.outer.stroke.green)
          @get('outerRect').strokeBlue(   @color_params.boxSelected.collision.outer.stroke.blue)
          @get('outerRect').strokeAlpha(  @color_params.boxSelected.collision.outer.stroke.alpha)
      else
        @get('rect').fillRed(           @color_params.boxSelected.uncollision.inner.red)
        @get('rect').fillGreen(         @color_params.boxSelected.uncollision.inner.green)
        @get('rect').fillBlue(          @color_params.boxSelected.uncollision.inner.blue)
        @get('rect').fillAlpha(         @color_params.boxSelected.uncollision.inner.alpha)
        @get('rect').strokeRed(         @color_params.boxSelected.uncollision.inner.stroke.red)
        @get('rect').strokeGreen(       @color_params.boxSelected.uncollision.inner.stroke.green)
        @get('rect').strokeBlue(        @color_params.boxSelected.uncollision.inner.stroke.blue)
        @get('rect').strokeAlpha(       @color_params.boxSelected.uncollision.inner.stroke.alpha)
        if @hasOuterRect()
          @get('outerRect').fillRed(      @color_params.boxSelected.uncollision.outer.red)
          @get('outerRect').fillGreen(    @color_params.boxSelected.uncollision.outer.green)
          @get('outerRect').fillBlue(     @color_params.boxSelected.uncollision.outer.blue)
          @get('outerRect').fillAlpha(    @color_params.boxSelected.uncollision.outer.alpha)
          @get('outerRect').strokeRed(    @color_params.boxSelected.uncollision.outer.stroke.red)
          @get('outerRect').strokeGreen(  @color_params.boxSelected.uncollision.outer.stroke.green)
          @get('outerRect').strokeBlue(   @color_params.boxSelected.uncollision.outer.stroke.blue)
          @get('outerRect').strokeAlpha(  @color_params.boxSelected.uncollision.outer.stroke.alpha)

  printPoints: (prefix) ->
    Logger.debug(   "\n[#{prefix}]: PointA(x:#{@getPointA().x},y:#{@getPointA().y})\n " +
                  "[#{prefix}]: PointB(x:#{@getPointB().x},y:#{@getPointB().y})\n " +
                  "[#{prefix}]: PointC(x:#{@getPointC().x},y:#{@getPointC().y})\n " +
                  "[#{prefix}]: PointD(x:#{@getPointD().x},y:#{@getPointD().y})\n " )

class @Boxes extends Backbone.Collection
  model: Box
  initialize: (params)->
    @layer = params.layer
    @zone = params.zone
    @box_params = 
      box:    params.box
      color:  params.color
      ratio:  params.ratio
      zone:   params.zone
    @CurrentBox = Backbone.Model.extend(
      initialize: (box_params)->
        @set box:         new Box(box_params)
        @set title:       @get('box').getTitleName()
        @on('change:box', @updateBoxTitle)
      updateBoxTitle: ->
        @set title: @get('box').getTitleName()
    )
    @on('all', @draw) 
    @on('all', @updateDashboardStatus)

    @collisionUtil = new CollisionUtil

    @currentBox = new Box(@box_params)
    @otherCurrentBox = new @CurrentBox(@box_params)

    @availableNewBoxId = 1

    # view.unbind()
    @rivetsBinder = rivets.bind $('.boxes'),{boxes: this}
    @flash = "Initialized completed!"

  availableNewTitle: () ->
    @length + 1
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
  createNewBox: =>
    newBox  = new Box(@box_params)

    # newBox.setXPosition(Math.min(@zone.bound.left + @availableNewBoxId * newBox.getMoveOffset(), @zone.bound.right))
    # newBox.setYPosition(Math.min(@zone.bound.top + @availableNewBoxId * newBox.getMoveOffset(), @zone.bound.bottom))
    if @length == 0
      newBox.setXPosition((@zone.bound.left + @zone.bound.right - newBox.get('rect').getWidth())/2)
      newBox.setYPosition((@zone.bound.top + @zone.bound.bottom - newBox.get('rect').getHeight())/2)
    else
      newBox.setXPosition(@last().getXPosition())
      newBox.setYPosition(@last().getYPosition())
    
    newBox.setTitleName(@availableNewBoxId)
    newBox.set('boxId', @availableNewBoxId)
    newBox.box().on "click", =>
      Logger.debug "box#{newBox.getTitleName()} clicked!"
      @flash =  "box#{newBox.getTitleName()} selected!"
      @updateCurrentBox(newBox)

    @add(newBox)
    @updateCurrentBox(newBox)
    @flash =  "box#{@currentBox.getTitleName()} selected!"
    @availableNewBoxId += 1

    @testCollision()

    Logger.debug("create button clicked!")
  settleCurrentBox: =>
    if @currentBox.get('collisionStatus')
      @flash = "Box#{@currentBox.getTitleName()} cannot be placed in collision status!"
    else
      @currentBox.set('settledStatus', true)
      @draw()
  removeCurrentBox: =>
    Logger.debug "#{@length}"
    if @length == 0
      @flash = 'There is no box.'
    else
      @deleteCollisionWith()
      @currentBox.get('group').destroy()
      @remove(@currentBox)
      if @length == 0
        @currentBox = new Box(@box_params) # for alert from rivetsjs
        @updateCurrentBox(new Box(@box_params))
        @flash = 'There is no box.'
      else
        # @currentBox = @last()
        @updateCurrentBox(@last())

    @draw()
    @flash =  "box#{@currentBox.getTitleName()} selected!"
    Logger.debug("remove button clicked!")
  testCollision:()->
    Logger.debug("...Collision start...")
    result = false
    result =_.reduce(@models,
                    ((status, box) ->
                      if @currentBox.getBoxId() != box.getBoxId() && @currentBox.getBoxId() != '0'
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
      Logger.debug("In draw: Box#{box.getTitleName()}.collision=#{box.get('collisionStatus')}")
      box.changeFillColor()
      box.updateTitle(index + 1) # keep box name as number sequence.
      @layer.add(box.box())
      index += 1
    @layer.draw()

  updateCurrentBox: (newBox = @currentBox) ->
    _.each(@models,((aBox) ->
          aBox.set('settledStatus', true)
          ),this)
    newBox.set('settledStatus', false)
    @currentBox = newBox
    Logger.debug "[updateCurrentBox] width: #{@currentBox.get('rect').getWidth()}, height: #{@currentBox.get('rect').getHeight()}"
    @otherCurrentBox.set('box', newBox)
    
    @updateBinders()
    rivets.bind $('.box'),{box: newBox}
  rotate90: () =>
    @currentBox.rotateWithAngle(90)
    @repairCrossZone(@currentBox) unless @validateZone(@currentBox)  
    @testCollision()
    @updateCurrentBox()
    Logger.debug "[rotate90] width: #{@currentBox.get('rect').getWidth()}, height: #{@currentBox.get('rect').getHeight()}"
  up: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setYPosition(@currentBox.getYPosition() - @currentBox.getMoveOffset())
    unless @validateZone(@currentBox)
      @repairCrossZone(@currentBox)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved UP!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
    @testCollision()
    @updateCurrentBox()
  down: () =>
    @currentBox.setYPosition(@currentBox.getYPosition() + @currentBox.getMoveOffset())
    unless @validateZone(@currentBox)
      # @currentBox.setYPosition(@zone.bound.bottom - @currentBox.getHeight())
      # @currentBox.set('crossZoneBottom', false)
      @repairCrossZone(@currentBox)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved DOWN!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
    @testCollision()
    @updateCurrentBox()
  left: () =>
    Logger.debug("@currentBox:\t" + @currentBox.getTitleName())
    @currentBox.setXPosition(@currentBox.getXPosition() - @currentBox.getMoveOffset())
    @currentBox.set('crossZoneLeft', false)
    unless @validateZone(@currentBox)
      @repairCrossZone(@currentBox)
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
      @repairCrossZone(@currentBox)
      @flash = "Box#{@currentBox.getTitleName()} cannot be moved RIGHT!"
    else
      @flash =  "box#{@currentBox.getTitleName()} selected!"
    @testCollision()
    @updateCurrentBox()
  validateZone: (box) ->
    result = _.reduce([box.getPointA(),box.getPointB(),box.getPointC(),box.getPointD()], 
                ((status, point) ->
                  status && @validateZoneX(point, box) && @validateZoneY(point, box)), 
                  true, this)
    Logger.debug("validresult:\t #{result}")
    result
  validateZoneX: (point, box) ->
    Logger.debug("validateZoneX: @zone.bound.left #{@zone.bound.left} point (#{point.x},#{point.y},#{point.flag}), @zone.bound.right #{@zone.bound.right}")
    if @zone.bound.left > point.x
      box.set('crossZoneLeft', true)
      false
    else if  point.x > @zone.bound.right
      box.set('crossZoneRight', true)
      false
    else
      true
  validateZoneY: (point, box) ->
    Logger.debug("validateZoneY: @zone.bound.top #{@zone.bound.top} point (#{point.x},#{point.y},#{point.flag}), @zone.bound.bottom #{@zone.bound.bottom}")
    if @zone.bound.top > point.y
      box.set('crossZoneTop', true)
      false
    else if  point.y > @zone.bound.bottom
      box.set('crossZoneBottom', true)
      false
    else
      true
  repairCrossZone: (box) ->
    Logger.debug "[repairCrossZone before]: crossZoneLeft: #{box.get('crossZoneLeft')} crossZoneRight: #{box.get('crossZoneRight')}"
    Logger.debug "[repairCrossZone before]: crossZoneTop: #{box.get('crossZoneTop')} crossZoneBottom: #{box.get('crossZoneBottom')}"
    Logger.debug "[repairCrossZone before]: x: #{box.getXPosition()} y: #{box.getYPosition()}"

    if box.get('crossZoneLeft') 
      box.setXPosition(@zone.bound.left)
    if box.get('crossZoneRight') 
      box.setXPosition(@zone.bound.right - box.getWidth())
    if box.get('crossZoneTop') 
      box.setYPosition(@zone.bound.top)
    if box.get('crossZoneBottom') 
      box.setYPosition(@zone.bound.bottom - box.getHeight())
    box.set
      crossZoneLeft:    false
      crossZoneRight:   false
      crossZoneTop:     false
      crossZoneBottom:  false
    Logger.debug "[repairCrossZone after]: x: #{box.getXPosition()} y: #{box.getYPosition()}"
    Logger.debug "[repairCrossZone after]: crossZoneLeft: #{box.get('crossZoneLeft')} crossZoneRight: #{box.get('crossZoneRight')}"
    Logger.debug "[repairCrossZone after]: crossZoneTop: #{box.get('crossZoneTop')} crossZoneBottom: #{box.get('crossZoneBottom')}"
    
  ## view controller
  ## should be a controller alone
  updateDashboardStatus: () ->
    settledStatuses = 
      _.reduce @models, ((status, aBox) ->
        Logger.debug "[updateDashboardStatus]: Box#{aBox.getTitleName()} settledStatus #{aBox.get('settledStatus') }" 
        status && aBox.get('settledStatus') 
        ), true
    if settledStatuses
      # all box are settled
      # create button is enabled
      $('#createNewBox').prop "disabled", false
      $("button.placeCurrentBox").each ->
        $(this).prop "disabled", true
    else
      $('#createNewBox').prop "disabled", true
      # $('#placeCurrentBox').prop "disabled", false
      $("button.placeCurrentBox").each ->
        $(this).prop "disabled", false

  updateBinders: () ->
    @rivetsBinder.unbind()
    @rivetsBinder = rivets.bind $('.boxes'),{boxes: this}
    Logger.debug "[updateBinders]: #{@flash}"
  showFlash: () ->
    @flash
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
        Logger.debug "In makeUnCollisionRelationAll: Pair#{this.boxId}, withBox#{aRelation.get('boxId')} #{aRelation.get('status')}"
        ),this)
class CollisionUtil extends Backbone.Collection
  model: CollisionPair

  initialize: ->
    # @on("change", @pprint)

  pprint: () ->
    _.each(@models, (pair) ->
      Logger.debug "In CollisionUtil: pair.#{pair.pprint()}")
  findPair:(boxId) ->
    aPair = _.find @models, (pair) ->
          pair.boxId == boxId
    # if aPair == undefined
    #   aPair = new CollisionPair(boxId: boxId)
    #   @add(aPair)
    aPair
  removeCollisionPair:(boxA, boxB) ->
    Logger.debug("removeCollisionPair: box#{boxA.getBoxId()}, box#{boxB.getBoxId()}")
    @updateCollisionRelationBetween(action: 'remove', boxAId: boxA.getBoxId(), boxBId: boxB.getBoxId())
    Logger.debug("@isCollisionInclude(boxA) #{@isCollisionInclude(boxA)}  isCollisionInclude(boxB) #{ @isCollisionInclude(boxB)}")
    unless @isCollisionInclude(boxA)
      boxA.makeUnCollisionStatus()
    unless @isCollisionInclude(boxB)
      boxB.makeUnCollisionStatus()

  addCollisionPair:(boxA, boxB) ->
    Logger.debug("addCollisionPair: box#{boxA.getBoxId()}, box#{boxB.getBoxId()}")
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
      Logger.debug("CollisionUtil:\t addPair:  box#{boxAPair.boxId} box#{boxBPair.boxId}")
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
      Logger.debug("CollisionUtil:\t removePair:  box#{boxAPair.boxId} box#{boxBPair.boxId}")
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

          Logger.debug("In delete: toDeletedBoxId: #{toDeletedBoxId}")
          Logger.debug("In delete: pair Relation: #{pair.pprint()}")
          Logger.debug("In delete: toDeletedBoxPair Relation: #{toDeletedBoxPair.pprint()}")
        ),this)
    else if options.action == 'changeID'
      Logger.debug("CollisionUtil:\t changeID box")
    Logger.debug("---->Show pair status: ")
    @pprint()
    Logger.debug("<----Show pair status: ")
  isCollisionInclude:(boxA) ->
    boxAId = boxA.getBoxId()
    result= _.filter @models, (pair) ->
        pair.boxId != boxAId && pair.isCollisionWith(boxAId)
    status  = (result.length > 0)


  ######## public api ########
  testCollisionBetween:(boxA,boxB,options = {collisionType: 'inner-inner'}) ->
    status  =     false
    if options.collisionType == 'inner-inner'

      Logger.debug("testCollision -> inner-inner")

      boxATop =     boxA.getYPosition()
      boxABottom =  boxA.getYPosition() + boxA.getHeight()
      boxALeft   =  boxA.getXPosition()
      boxARight  =  boxA.getXPosition() + boxA.getWidth()
      boxBTop    =  boxB.getYPosition()
      boxBBottom =  boxB.getYPosition() + boxB.getHeight()
      boxBLeft   =  boxB.getXPosition()
      boxBRight  =  boxB.getXPosition() + boxB.getWidth()
    else if options.collisionType == 'outer-outer'
      if boxA.hasOuterRect()
        Logger.debug("testCollision -> inner-inner  boxA:#{boxA.getTitleName()} outer")
        boxATop =     boxA.getYPosition({innerOrOuter: 'outer'})
        boxABottom =  boxA.getYPosition({innerOrOuter: 'outer'}) + boxA.getHeight({innerOrOuter: 'outer'})
        boxALeft   =  boxA.getXPosition({innerOrOuter: 'outer'})
        boxARight  =  boxA.getXPosition({innerOrOuter: 'outer'}) + boxA.getWidth({innerOrOuter: 'outer'})

        boxBTop    =  boxB.getYPosition()
        boxBBottom =  boxB.getYPosition() + boxB.getHeight()
        boxBLeft   =  boxB.getXPosition()
        boxBRight  =  boxB.getXPosition() + boxB.getWidth()
      else
        Logger.debug("testCollision -> inner-inner  boxB:#{boxB.getTitleName()} outer")
        boxATop =     boxA.getYPosition()
        boxABottom =  boxA.getYPosition() + boxA.getHeight()
        boxALeft   =  boxA.getXPosition()
        boxARight  =  boxA.getXPosition() + boxA.getWidth()

        boxBTop    =  boxB.getYPosition({innerOrOuter: 'outer'})
        boxBBottom =  boxB.getYPosition({innerOrOuter: 'outer'}) + boxB.getHeight({innerOrOuter: 'outer'})
        boxBLeft   =  boxB.getXPosition({innerOrOuter: 'outer'})
        boxBRight  =  boxB.getXPosition({innerOrOuter: 'outer'}) + boxB.getWidth({innerOrOuter: 'outer'})
    
    status = true  unless boxABottom < boxBTop or boxATop > boxBBottom or boxALeft > boxBRight or boxARight < boxBLeft
    Logger.debug("testCollisionBetween: box#{boxA.getBoxId()} box#{boxB.getBoxId()} #{status}")     
    if status
      @addCollisionPair(boxA, boxB)
    else
      @removeCollisionPair(boxA, boxB)
    status

class @StackBoard
  constructor:(params) ->
    #background_color: rgb(255,​ 228,​ 196)
    
    longerEdge = Math.max(pallet.width, pallet.height)
    shorterEdge = Math.min(pallet.width, pallet.height)
    # margin = pallet.overhang + box.minDistance

    Logger.debug "pallet.overhang: #{pallet.overhang}, box.minDistance: #{box.minDistance}, margin: #{margin}"
    # overhangOffset = {x: 0 , y: 0, edge: margin}

    # if margin > 0
    #   overhangOffset.x = overhangOffset.y = box.minDistance
    #   @ratio = Math.min(params.stage.height / (longerEdge + 2 * margin), params.stage.width / (shorterEdge + 2 * margin))
    # else
    #   overhangOffset.x = overhangOffset.y = 0 - pallet.overhang
    #   margin = 0
    #   @ratio = Math.min(params.stage.height / (longerEdge + 2 * margin), params.stage.width / (shorterEdge + 2 * margin))

    margin = pallet.overhang
    overhangOffset = {x: 0 , y: 0}
    if margin > 0
      @ratio = Math.min(params.stage.height / (longerEdge + 2 * margin), params.stage.width / (shorterEdge + 2 * margin))
    else
      overhangOffset.x = overhangOffset.y = 0 - margin
      margin = 0
      @ratio = Math.min(params.stage.height / (longerEdge + 2 * margin), params.stage.width / (shorterEdge + 2 * margin))
 
    stageBackground = new Kinetic.Rect(
        x:            0
        y:            0
        width:        params.stage.width
        height:       params.stage.height
        fillRed:      params.color.stage.red
        fillGreen:    params.color.stage.green
        fillBlue:     params.color.stage.blue
      )
    palletBackground = new Kinetic.Rect(
        x:            margin * @ratio
        y:            margin * @ratio
        width:        shorterEdge * @ratio
        height:       longerEdge * @ratio
        fillRed:      params.color.pallet.red
        fillGreen:    params.color.pallet.green
        fillBlue:     params.color.pallet.blue
      )

    @zone = 
        x: overhangOffset.x * @ratio
        y: overhangOffset.y * @ratio 
        width: (shorterEdge + pallet.overhang * 2) * @ratio
        height:(longerEdge + pallet.overhang * 2) * @ratio
        bound:
          top:      overhangOffset.y * @ratio  # y
          bottom:   overhangOffset.y * @ratio + (longerEdge + pallet.overhang * 2) * @ratio # y + height
          left:     overhangOffset.x * @ratio # x
          right:    overhangOffset.x * @ratio + (shorterEdge + pallet.overhang * 2) * @ratio # x + width 

    overhangBackground = new Kinetic.Rect(
        x:              @zone.x
        y:              @zone.y
        width:          @zone.width
        height:         @zone.height
        strokeRed:      params.color.overhang.stroke.red
        strokeGreen:    params.color.overhang.stroke.green
        strokeBlue:     params.color.overhang.stroke.blue
        strokeAlpha:    params.color.overhang.stroke.alpha
      )
    overhangBackground.dash(([4, 5]))

    @stage = new Kinetic.Stage(
      container: "canvas_container"
      width:  params.stage.width * params.stage.stage_zoom
      height: params.stage.height * params.stage.stage_zoom
    )

    @layer = new Kinetic.Layer()

    @stage.add @layer

    @layer.add stageBackground
    @layer.add palletBackground
    @layer.add overhangBackground

    #### flip context
    # @layer.getContext().translate(0, @zone.height + @zone.y * 2)
    # @layer.getContext().scale(1, -1);

    Logger.debug("StackBoard: Stage Initialized!")
    Logger.info("StackBoard: Initialized!")

    boxByRatio = 
        x:      params.box.x
        y:      params.box.y
        width:  params.box.width * @ratio 
        height: params.box.height * @ratio
        minDistance: params.box.minDistance * @ratio

    boxes_params = {layer: @layer, zone: @zone, box: boxByRatio, color: params.color, ratio: @ratio}
    @boxes = new Boxes(boxes_params)
    @currentBox = @boxes.otherCurrentBox
    @boxes.shift()

    rivets.bind $('.currentBox'),{currentBox: @currentBox}

#### Params ####
# unit: pixal
# canvas available paiting zone
canvasStage =  
  width:      280
  height:     360 
  stage_zoom: 1.5

# color: RGB
color = 
    stage:   
        red:    255
        green:  255
        blue:   255
    pallet: 
        red:    251
        green:  209
        blue:   175
    overhang: 
        stroke:
          red:    238
          green:  49
          blue:   109
          alpha:  0.5
    boxPlaced:
      inner:
        red:    0
        green:  0
        blue:   255
        alpha:  1
        stroke:
          red:    147
          green:  218
          blue:   87
          alpha:  0.5
      outer:
        red:    0
        green:  0
        blue:   0
        alpha:  0
        stroke:
          red:    0
          green:  0
          blue:   0
          alpha:  0
    boxSelected:
      collision:
        inner:
          red:    255
          green:  0
          blue:   0
          alpha:  1
          stroke:
            red:    147
            green:  218
            blue:   87
            alpha:  0.5
        outer:
          red:    255
          green:  0
          blue:   0
          alpha:  0.5
          stroke:
            red:    255
            green:  0
            blue:   0
            alpha:  0.5           
      uncollision:
        inner:
          red:    0
          green:  255
          blue:   0
          alpha:  1
          stroke:
            red:    147
            green:  218
            blue:   87
            alpha:  0.5
        outer:
          red:    0
          green:  0
          blue:   0
          alpha:  0
          stroke:
            red:    255
            green:  255
            blue:   0
            alpha:  0.5          

# unit: cm
pallet =  
  width:    390
  height:   500 
  overhang: 20
box  =      
  x:      0 
  y:      0
  width:  120  
  height: 60  
  minDistance: 30
    
params = 
  pallet: pallet
  box: box
  stage: canvasStage
  color: color

################


@board = new StackBoard(params)

rivets.formatters.suffix_cm = (value) ->
   "#{value.toFixed(2)}"

rivets.formatters.availableNewTitle = (value) ->
  "#{value + 100}"

$("input").prop "readonly", true


# $(".currentBox").prop "readonly", false
# $(".offset").prop "readonly", false



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



