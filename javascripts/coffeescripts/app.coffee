require.config(
  baseUrl: "./javascripts"
  dir: "../dist"
  optimize: "uglify"
  optimizeCss: "standard.keepLines"
  removeCombined: true
  fileExclusionRegExp: /^\./
  # modules: [
  #   name: "app/dispatcher"
  # ,
  #   name: "app/in-storage"
  #   exclude: [ "jquery", "app/common", "pkg/DatePicker/app" ]
  #  ]
  paths:
    jquery: "lib/jquery"
    underscore: "lib/underscore"
    backbone: "lib/backbone"
    rivets: "lib/rivets"
    kinetic: "lib/kinetic"
    bootstrap: 'lib/bootstrap'

  shim:
    underscore:
      exports: "_"

    backbone:
      deps: [ "underscore", "jquery" ]
      exports: "Backbone"
    rivets:
      exports: "rivets"
    kinetic:
      exports: "Kinetic"
    bootstrap:
      deps: [ "jquery" ]
      exports: "Bootstrap"
)

require ['jquery', 'underscore', 'backbone', 'rivets', 'kinetic', 'bootstrap'], ($, _, Backbone, rivets, Kinetic) ->
  # "use strict"

  console.log Backbone
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
      moveOffset:       1
      rotate:           0

      vectorDegree:     0
      vectorEnabled:    false

      crossZoneLeft:    false
      crossZoneRight:   false
      crossZoneTop:     false
      crossZoneBottom:  false
    }
    initialize: (params) ->
      @on('change:rect', @rectChanged)
      #Fill Color: rgb(60, 118, 61)
      
      [box_params, @color_params, @ratio, @zone, @palletOverhang] = [params.box, params.color, params.ratio, params.zone, params.palletOverhang]
      @set minDistance: box_params.minDistance
      # innerBox is stable and origin value of box.
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
                                    x:            @get('rect').x() + @get('rect').width() - 5
                                    y:            @get('rect').y() +  5
                                    fontSize:     14
                                    fontFamily:   "Calibri"
                                    fill:         "white"
                                    text:         @get('boxId')
                                    rotate:       0
                                    offset:       {x:4 , y:4 }
                                  )

      centerPointOnRect = @getCenterPoint('inner')
      @set dot:  new Kinetic.Circle(
                                    x: centerPointOnRect.x
                                    y: centerPointOnRect.y
                                    radius: 2
                                    fillRed:    1
                                    fillGreen:  1
                                    fillBlue:   1 
                                    fillAlpha:  1
                                  )

      @set arrow: new Kinetic.Line(
                                    x: centerPointOnRect.x
                                    y: centerPointOnRect.y
                                    points: [
                                      centerPointOnRect.x
                                      centerPointOnRect.y  + 8
                                      
                                      centerPointOnRect.x
                                      centerPointOnRect.y - 8
                                      
                                      centerPointOnRect.x - 4
                                      centerPointOnRect.y 
                                      
                                      centerPointOnRect.x
                                      centerPointOnRect.y - 8 

                                      centerPointOnRect.x + 4
                                      centerPointOnRect.y
                                    ]
                                    strokeRed:    1
                                    strokeGreen:  1
                                    strokeBlue:   1
                                    strokeWidth:  2
                                    strokeAlpha:  0
                                    lineCap: "round"
                                    lineJoin: "round"
                                    offset:       {x:centerPointOnRect.x , y:centerPointOnRect.y }
                                  )
      @set innerShape: 
        x:      @get('rect').x() + @get('rect').width()/8
        y:      @get('rect').y()
        width:  @get('rect').width() * 0.75
        height: @get('rect').height() / 8

      @set orientationFlag: new Kinetic.Rect(
                                    x:            @get('innerShape').x
                                    y:            @get('innerShape').y
                                    width:        @get('innerShape').width
                                    height:       @get('innerShape').height
                                    # fill:         'red'
                                    fillRed:      255
                                    fillGreen:    41
                                    fillBlue:     86
                                  )
      @set group: new Kinetic.Group(
                                    x: 0
                                    y: 0
                                    draggable: false
                                  )
      @get('rect').dash(([4, 5]))
      @get('group').add(@get('rect'))
      @get('group').add(@get('title'))
      @get('group').add(@get('arrow'))
      @get('group').add(@get('dot'))
      @get('group').add(@get('orientationFlag'))
      
      ###### Box has an outer Rect ######
      # box_params.minDistance = $("input:checked","#minDistanceRadio").val()
      outerBox = @getOuterRectShape()
      @set outerRect: new Kinetic.Rect(
                              x:              outerBox.x
                              y:              outerBox.y
                              width:          outerBox.width
                              height:         outerBox.height
                            )
      unless @get('minDistance') > 0
        @get('outerRect').setFillAlpha(0)
      @get('outerRect').dash(([4, 5]))
      @get('group').add(@get('outerRect'))

      Logger.debug('Box: Generate a new box.')

    hasOuterRect: () ->
      @get('minDistance') > 0

    getCenterPoint: (options) ->
      if options == 'inner'
        centerPointOnRect = 
          x:  @get('rect').x() + @get('rect').width() / 2
          y:  @get('rect').y() + @get('rect').height() / 2
      else if options == 'byRatio'
          x:  (@get('group').x() + @get('rect').width() / 2) / @ratio
          y:  (@get('group').y() + @get('rect').height() / 2) /@ratio
      else
        centerPointOnGroup = 
          x:  @get('group').x() + @get('rect').width() / 2
          y:  @get('group').y() + @get('rect').height() / 2

    getOuterRectShape: () ->
      shape =  
        x:      @get('innerBox').x - @get('minDistance')
        y:      @get('innerBox').y - @get('minDistance')
        width:  @get('innerBox').width + 2 * @get('minDistance')
        height: @get('innerBox').height + 2 * @get('minDistance')

    getBoxId: () ->
      @get('boxId') 
    getMoveOffset: () ->
      Logger.debug "getMoveOffset #{@get('moveOffset')}"
      # moveoffset * ratio = unit mm, not unit px
      (Math.round(parseFloat(Number(@get('moveOffset') * @ratio))*100)/100)
      # Number(@get('moveOffset') * @ratio)

    setTitleName: (newTitle) ->
      @get('title').setText(newTitle) 
    getTitleName: () ->
      @get('title').text() 
    setXPosition: (x) ->
      @get('group').setX(x)
    getXPositionByRatio: () ->
      # the center point x
      ((@get('group').x() + @get('rect').getWidth() / 2) - @zone.bound.left) / @ratio - @palletOverhang
    getYPositionByRatio: ()  ->   
      (@zone.bound.bottom - (@get('group').y() - @get('rect').getHeight() / 2) - @getHeight()) / @ratio - @palletOverhang
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
      newRotateAngle = (@get('rotate') + angle) % 360
      centerPointForGroup    = @getCenterPoint()

      # @set innerShape: 
      #   x:      @get('rect').x() + @get('rect').width()/8
      #   y:      @get('rect').y()
      #   width:  @get('rect').width() * 0.75
      #   height: @get('rect').height() / 8
      switch newRotateAngle
        when 0
          @get('rect').setWidth(@get('innerBox').width)
          @get('rect').setHeight(@get('innerBox').height)
          @get('group').setX(centerPointForGroup.x - @get('rect').getWidth() / 2 )
          @get('group').setY(centerPointForGroup.y - @get('rect').getHeight() / 2 )

          outerBox = @getOuterRectShape()
          @get('outerRect').setWidth(outerBox.width)
          @get('outerRect').setHeight(outerBox.height)

          shape = @get('innerShape')
          @get('orientationFlag').setX(@get('rect').width()/8)
          @get('orientationFlag').setY(0)
          @get('orientationFlag').setWidth(shape.width)
          @get('orientationFlag').setHeight(shape.height)

        when 90
          @get('rect').setWidth(@get('innerBox').height)
          @get('rect').setHeight(@get('innerBox').width)
          @get('group').setX(centerPointForGroup.x - @get('rect').getWidth() / 2 )
          @get('group').setY(centerPointForGroup.y - @get('rect').getHeight() / 2 )

          outerBox = @getOuterRectShape()
          @get('outerRect').setWidth(outerBox.height)
          @get('outerRect').setHeight(outerBox.width)

          shape = @get('innerShape')
          @get('orientationFlag').setX(@get('rect').width()/8 * 7)
          @get('orientationFlag').setY(@get('rect').height()/8)
          @get('orientationFlag').setWidth(shape.height)
          @get('orientationFlag').setHeight(shape.width)

        when 180
          @get('rect').setWidth(@get('innerBox').width)
          @get('rect').setHeight(@get('innerBox').height)
          @get('group').setX(centerPointForGroup.x - @get('rect').getWidth() / 2 )
          @get('group').setY(centerPointForGroup.y - @get('rect').getHeight() / 2 )

          outerBox = @getOuterRectShape()
          @get('outerRect').setWidth(outerBox.width)
          @get('outerRect').setHeight(outerBox.height)

          shape = @get('innerShape')
          @get('orientationFlag').setX(@get('rect').width()/8)
          @get('orientationFlag').setY(@get('rect').height()/8 * 7)
          @get('orientationFlag').setWidth(shape.width)
          @get('orientationFlag').setHeight(shape.height)

        when 270
        # 90,270

          @get('rect').setWidth(@get('innerBox').height)
          @get('rect').setHeight(@get('innerBox').width)
          @get('group').setX(centerPointForGroup.x - @get('rect').getWidth() / 2 )
          @get('group').setY(centerPointForGroup.y - @get('rect').getHeight() / 2 )

          outerBox = @getOuterRectShape()
          @get('outerRect').setWidth(outerBox.height)
          @get('outerRect').setHeight(outerBox.width)

          shape = @get('innerShape')
          @get('orientationFlag').setX(0)
          @get('orientationFlag').setY(@get('rect').height()/8)
          @get('orientationFlag').setWidth(shape.height)
          @get('orientationFlag').setHeight(shape.width)

      @get('arrow').setX(@get('rect').x() + @get('rect').width()/2)
      @get('arrow').setY(@get('rect').y() + @get('rect').height()/2)
      @get('dot').setX(@get('rect').x() + @get('rect').width()/2)
      @get('dot').setY(@get('rect').y() + @get('rect').height()/2)

      @get('title').setX(@get('rect').x() + @get('rect').width()   - 5)
      @get('title').setY(@get('rect').y() + 5)
      @set('rotate',newRotateAngle)

      Logger.debug "[rotateWithAngle] width: #{@get('rect').getWidth()}, height: #{@get('rect').getHeight()}"
      Logger.debug   "[rotateWithAngle] group_x: #{@get('group').x()}, group_y: #{@get('group').y()}"
      Logger.debug   "[rotateWithAngle] rect_x: #{@get('rect').x()}, rect_y: #{@get('rect').y()}"
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
      @knob = params.knob
      @box_params = 
        box:    params.box
        color:  params.color
        ratio:  params.ratio
        zone:   params.zone
        palletOverhang: params.palletOverhang


      @ratio = @box_params.ratio

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
      @rivetsBinderCurrentBox = rivets.bind $('.currentBox'),{currentBox: @otherCurrentBox}
      @flash = "Initialized completed!"

      @alignGroup = new Kinetic.Group(
                                    x: 0
                                    y: 0
                                    draggable: false
                                  )

      @xAlignLine = new Kinetic.Line(
                                    points: [
                                      0
                                      0
                                      
                                      0
                                      0
                                    ]
                                    strokeRed:    65
                                    strokeGreen:  219
                                    strokeBlue:   248
                                    strokeWidth:  1
                                    strokeAlpha:  0
                                    lineCap: "round"
                                    lineJoin: "round"
                                  )
      @yAlignLine = new Kinetic.Line(
                                    points: [
                                      0
                                      0
                                      
                                      0
                                      0
                                    ]
                                    strokeRed:    65
                                    strokeGreen:  219
                                    strokeBlue:   248
                                    strokeWidth:  1
                                    strokeAlpha:  0
                                    lineCap: "round"
                                    lineJoin: "round"
                                  )
      @alignGroup.add @xAlignLine
      @alignGroup.add @yAlignLine


      @layer.add @alignGroup

    precisionAdjustment: (floatNumber, digitNumber = 0) ->
      ratioBy10 = 1 * Math.pow(10,digitNumber)
      Math.round(parseFloat(floatNumber)*ratioBy10)/ratioBy10

    equalCompareWithFloatNumber: (numberLeft, numberRight,digitNumber = 0) ->
      Logger.debug "[equalCompareWithFloatNumber:] numberLeft #{@precisionAdjustment(numberLeft)}"
      Logger.debug "[equalCompareWithFloatNumber:] numberRight #{@precisionAdjustment(numberRight)}"
      Logger.debug "#{@precisionAdjustment(numberLeft) == @precisionAdjustment(numberRight)}"
      @precisionAdjustment(numberLeft) == @precisionAdjustment(numberRight)
    nearCompareWithFloatNumber: (numberLeft, numberRight, offset, digitNumber = 0 ) ->
      Math.abs(@precisionAdjustment(numberLeft) - @precisionAdjustment(numberRight)) < offset
    updateAlignGroup: (options={}) ->
      Logger.debug "[updateAlignGroup] before: box#{@currentBox.getTitleName()}"
      return if @length <= 1
      @hideAlignLines()

      currentBoxCenterPoint = @currentBox.getCenterPoint()
      currentBoxCenterPointByRatio = @currentBox.getCenterPoint('byRatio')

      leftBox = rightBox = topBox = bottomBox = @currentBox
      leftSpan = rightSpan = topSpan = bottomSpan = 0

      leftBoxApproach = rightBoxApproach = topBoxApproach = bottomBoxApproach = @currentBox
      leftSpanApproach = rightSpanApproach = topSpanApproach = bottomSpanApproach = 0

      xAlignFlag = ''
      yAlignFlag = ''

      _.each(@models,((aBox) ->
        if aBox.getBoxId() != @currentBox.getBoxId()
          aBoxCenterPoint = aBox.getCenterPoint()
          aBoxCenterPointByRatio = aBox.getCenterPoint('byRatio')

          #approach
          if @nearCompareWithFloatNumber(aBox.getCenterPoint('byRatio').y, currentBoxCenterPointByRatio.y, @currentBox.getWidthByRatio()/2)
             # have a same y value, find approach x
            newLeftSpanApproach   = currentBoxCenterPoint.x - aBoxCenterPoint.x
            newRightSpanApproach  = aBoxCenterPoint.x - currentBoxCenterPoint.x
            if newLeftSpanApproach > leftSpanApproach
              leftBoxApproach = aBox
              leftSpanApproach = newLeftSpanApproach
            if newRightSpanApproach > rightSpanApproach
              rightBoxApproach = aBox
              rightSpanApproach = newRightSpanApproach

            Logger.debug "[updateAlignGroup]:leftSpanApproach #{leftSpanApproach};  rightSpanApproach #{rightSpanApproach}"
            xAlignFlag = 'approach'       

          if @nearCompareWithFloatNumber(aBox.getCenterPoint('byRatio').x,currentBoxCenterPointByRatio.x, @currentBox.getWidthByRatio()/2)
            # have a same x value, find approach y
            newTopSpanApproach    = currentBoxCenterPoint.y - aBoxCenterPoint.y
            newBottomSpanApproach = aBoxCenterPoint.y - currentBoxCenterPoint.y

            if newBottomSpanApproach > bottomSpanApproach
              bottomBoxApproach = aBox
              bottomSpanApproach = newBottomSpanApproach
            if newTopSpanApproach > topSpanApproach
              topBoxApproach = aBox
              topSpanApproach = newTopSpanApproach
            yAlignFlag = 'approach'  

          # equal
          Logger.debug "aBox.getCenterPoint('byRatio').y - currentBoxCenterPointByRatio.y #{aBox.getCenterPoint('byRatio').y - currentBoxCenterPointByRatio.y}"
          if @equalCompareWithFloatNumber(aBox.getCenterPoint('byRatio').y, currentBoxCenterPointByRatio.y)
            # have a same y value, find align x
            newLeftSpan   = currentBoxCenterPoint.x - aBoxCenterPoint.x
            newRightSpan  = aBoxCenterPoint.x - currentBoxCenterPoint.x
            if newLeftSpan > leftSpan
              leftBox = aBox
              leftSpan = newLeftSpan
            if newRightSpan > rightSpan
              rightBox = aBox
              rightSpan = newRightSpan
            xAlignFlag = 'align'

          Logger.debug "aBox.getCenterPoint('byRatio').x - currentBoxCenterPointByRatio.x : #{aBox.getCenterPoint('byRatio').x - currentBoxCenterPointByRatio.x}"
          if @equalCompareWithFloatNumber(aBox.getCenterPoint('byRatio').x,currentBoxCenterPointByRatio.x)
            # have a same x value, find align y
            newTopSpan    = currentBoxCenterPoint.y - aBoxCenterPoint.y
            newBottomSpan = aBoxCenterPoint.y - currentBoxCenterPoint.y

            if newBottomSpan > bottomSpan
              bottomBox = aBox
              bottomSpan = newBottomSpan
            if newTopSpan > topSpan
              topBox = aBox
              topSpan = newTopSpan
            yAlignFlag = 'align'

      ),this)  

      if xAlignFlag == 'align'
        Logger.debug("[updateAlignGroup]: x align add: leftBox #{leftBox.getTitleName()}, rightBox #{rightBox.getTitleName()}")
        @updateYAlignLine(leftBox.getCenterPoint().x, rightBox.getCenterPoint().x, currentBoxCenterPoint.y, 50, 'alignment')
      else if xAlignFlag == 'approach'
        if leftBoxApproach.getTitleName() != @currentBox.getTitleName()
          notCurrentBox = leftBoxApproach
        else if rightBoxApproach.getTitleName() != @currentBox.getTitleName()
          notCurrentBox = rightBoxApproach
        else
          notCurrentBox = _.filter(@models, ((aBox) ->
                            aBox.getTitleName() != @currentBox.getTitleName()
                          ), this)[0]
        @updateYAlignLine(leftBoxApproach.getCenterPoint().x, rightBoxApproach.getCenterPoint().x, notCurrentBox.getCenterPoint().y, 50, 'approach')
      else
        @yAlignLine.strokeAlpha(0)

      if yAlignFlag == 'align'    
        Logger.debug("[updateAlignGroup]: y align add: topBox#{topBox.getTitleName()}: #{topBox.getCenterPoint().y}, bottomBox#{bottomBox.getTitleName()}: #{bottomBox.getCenterPoint().y}")
        @updateXAlignLine(topBox.getCenterPoint().y, bottomBox.getCenterPoint().y, currentBoxCenterPoint.x, 50, 'alignment')
      else if yAlignFlag == 'approach' 
        if topBoxApproach.getTitleName() != @currentBox.getTitleName()
          notCurrentBox = topBoxApproach
        else if bottomBoxApproach.getTitleName() != @currentBox.getTitleName()
          notCurrentBox = bottomBoxApproach 
        else
          notCurrentBox = _.filter(@models, ((aBox) ->
                            aBox.getTitleName() != @currentBox.getTitleName()
                          ), this)[0]
        @updateXAlignLine(topBoxApproach.getCenterPoint().y, bottomBoxApproach.getCenterPoint().y, notCurrentBox.getCenterPoint().x, 50, 'approach')
      else 
        @xAlignLine.strokeAlpha(0)

      Logger.debug "[updateAlignGroup] @xAlignLine.strokeAlpha(0) #{@xAlignLine.strokeAlpha()}"
      Logger.debug "[updateAlignGroup] @yAlignLine.strokeAlpha(0) #{@yAlignLine.strokeAlpha()}"
      Logger.debug "[updateAlignGroup] after: box#{@currentBox.getTitleName()}"
      @draw()

    hideAlignLines: () ->
      @xAlignLine.strokeAlpha(0)
      @yAlignLine.strokeAlpha(0)

    updateXAlignLine: (pointTopY, pointBottomY, pointX, offset, status) ->
      Logger.debug "[updateXAlignLine] pointTop: #{pointTopY}  pointBottom: #{pointBottomY}"
      @xAlignLine.strokeAlpha(1)
      @xAlignLine.points([pointX, pointTopY - offset, pointX, pointBottomY + offset])
      if status == 'approach'
        @xAlignLine.strokeRed(65)
        @xAlignLine.strokeGreen(219)
        @xAlignLine.strokeBlue(248)
      else
        @xAlignLine.strokeRed(255)
        @xAlignLine.strokeGreen(255)
        @xAlignLine.strokeBlue(27)
      @xAlignLine

    updateYAlignLine: (pointLeftX, pointRightX, pointY, offset, status) ->
      @yAlignLine.strokeAlpha(1)
      @yAlignLine.points([pointLeftX - offset, pointY, pointRightX + offset, pointY])
      if status == 'approach'
        @yAlignLine.strokeRed(65)
        @yAlignLine.strokeGreen(219)
        @yAlignLine.strokeBlue(248)
      else
        @yAlignLine.strokeRed(255)
        @yAlignLine.strokeGreen(255)
        @yAlignLine.strokeBlue(27)
      @yAlignLine

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

      if @length == 0
        newBox.setXPosition Math.floor((@zone.bound.left + @zone.bound.right - newBox.get('rect').getWidth())/2)
        newBox.setYPosition Math.floor((@zone.bound.top + @zone.bound.bottom - newBox.get('rect').getHeight())/2)

      else
        newBox.setXPosition(@last().getXPosition())
        newBox.setYPosition(@last().getYPosition())
      
      newBox.setTitleName(@availableNewBoxId)
      newBox.set('boxId', @availableNewBoxId)
      newBox.box().on "click", =>
        Logger.debug "box#{newBox.getTitleName()} clicked!"
        unless @testCollision()
          # newBox.get('collisionStatus')
          ## test all other box whether in collision status
          @flash =  "box#{newBox.getTitleName()} selected!"
          @updateCurrentBox(newBox)
          @draw()
        else
          @flash =  "Collision!"

      # newBox.box().on "dblclick", =>
      #   Logger.debug "box#{newBox.getTitleName()} double clicked!"
      #   if @currentBox.get('vectorEnabled')
      #     @currentBox.set('vectorEnabled', false)
      #     # change arrow to dot
      #     @currentBox.get('dot').setFillAlpha(1)
      #     @currentBox.get('arrow').strokeAlpha(0)
      #   else
      #     @currentBox.set('vectorEnabled', true)
      #     # change dot to arrow
      #     @currentBox.get('dot').setFillAlpha(0)
      #     @currentBox.get('arrow').strokeAlpha(1)
      #   Logger.debug "double click: dot: #{@currentBox.get('dot').fillAlpha()}; arrow: #{@currentBox.get('arrow').strokeAlpha()};"
      #   @updateCurrentBox()

      @add(newBox)
      @updateCurrentBox(newBox)
      @flash =  "box#{@currentBox.getTitleName()} selected!"
      @availableNewBoxId += 1

      @testCollision()
      @repairCrossZone(@currentBox) unless @validateZone(@currentBox)  

      Logger.debug("create button clicked!")
    settleCurrentBox: =>
      if @currentBox.get('collisionStatus')
        @flash = "Box#{@currentBox.getTitleName()} cannot be placed in collision status!"
      else
        @currentBox.set('settledStatus', true)
        @currentBox.get('group').setDraggable(false)
        @hideAlignLines()
        @draw()
    updateDragStatus: (draggableBox) ->
      _.each(@models,((aBox) ->
          if aBox.getBoxId() == draggableBox.getBoxId()
            draggableBox.get('group').setDraggable(true)
          else
            aBox.get('group').setDraggable(false)
        ), this)
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
      # Logger.debug("...Collision result: #{result}")
      # @draw()
    draw: () ->
      index = 0
      while index < @models.length
        box = @models[index]
        Logger.debug("In draw: Box#{box.getTitleName()}.collision=#{box.get('collisionStatus')}")
        box.changeFillColor()
        box.updateTitle(index + 1) # keep box name as number sequence.
        @layer.add(box.box())
        index += 1
        Logger.debug("[draw]: Box#{box.getTitleName()} #{box.box().draggable()}")
        Logger.debug("[draw]: X#{box.getXPosition()} Y#{box.getYPosition()}")
      @layer.add @alignGroup
      @layer.draw()

    updateCurrentBox: (newBox = @currentBox) ->
      _.each(@models,((aBox) ->
            aBox.set('settledStatus', true)
            ),this)
      newBox.set('settledStatus', false)
      @currentBox = newBox

      #dragg setting
      @currentBox.get('group').setDraggable(true)
      @currentBox.get('group').setDragBoundFunc((position) =>
        unless @validateZone(@currentBox)
          @repairCrossZone(@currentBox) 
          newPosition=
            x: @currentBox.getXPosition()
            y: @currentBox.getYPosition()
        else
          newPosition = position
        @updateCurrentBox()
        newPosition)

      @currentBox.get('group').on('dragend', =>
        @currentBox.setXPosition( @precisionAdjustment(@currentBox.getXPosition()) )
        @currentBox.setYPosition( @precisionAdjustment(@currentBox.getYPosition()) )
        @repairCrossZone(@currentBox) unless @validateZone(@currentBox)
        @testCollision())


      Logger.debug "[updateCurrentBox] width: #{@currentBox.get('rect').getWidth()}, height: #{@currentBox.get('rect').getHeight()}"
      @otherCurrentBox.set('box', newBox)
      
      @updateBinders()
      @updateDragStatus(@currentBox)
      @updateAlignGroup()
      rivets.bind $('.box'),{box: newBox}


    rotate90: () =>
      @currentBox.rotateWithAngle(90)
      # @repairCrossZone(@currentBox) unless @validateZone(@currentBox)  
      @testCollision()
      @updateCurrentBox()
      Logger.debug "[rotate90] width: #{@currentBox.get('rect').getWidth()}, height: #{@currentBox.get('rect').getHeight()}"
    rotateByVector: () =>
      vectorDegree = @currentBox.get('vectorDegree') + 45

      if vectorDegree <= 360 
        @currentBox.set('vectorEnabled', true)
        # change dot to arrow
        @currentBox.get('dot').setFillAlpha(0)
        @currentBox.get('arrow').strokeAlpha(1)
        @currentBox.set('vectorDegree', vectorDegree)
        @currentBox.get('arrow').rotation(@currentBox.get('vectorDegree'))
      else
        @currentBox.set('vectorEnabled', false)
        # change arrow to dot
        @currentBox.get('dot').setFillAlpha(1)
        @currentBox.get('arrow').strokeAlpha(0)
        @currentBox.set('vectorDegree', -45)

      Logger.debug "box#{@currentBox.getTitleName()} vector #{vectorDegree}"

      @updateCurrentBox()

    moveByVector: () =>
      moveDegree = $("input.dial").val()
      switch Number(moveDegree)
        when 0
          @moveByX(0)
          @moveByY(1)
        when 45
          @moveByX(1)
          @moveByY(1)
        when 90
          @moveByX(1)
          @moveByY(0)
        when 135
          @moveByX(1)
          @moveByY(-1)
        when 180
          @moveByX(0)
          @moveByY(-1)
        when 225
          @moveByX(-1)
          @moveByY(-1)
        when 270
          @moveByX(-1)
          @moveByY(0)
        when 315
          @moveByX(-1)
          @moveByY(1)
        when 360
          @moveByX(0)
          @moveByY(1)
      @testCollision()
      @updateCurrentBox()
    moveByY: (direction, flash) ->
      @currentBox.setYPosition(Math.round(parseFloat(@currentBox.getYPosition() - @currentBox.getMoveOffset() * direction)))
      @repairCrossZone(@currentBox) unless @validateZone(@currentBox)
      @flash = flash
    moveByX: (direction, flash) ->
      @currentBox.setXPosition(Math.round(parseFloat(@currentBox.getXPosition() + @currentBox.getMoveOffset() * direction)))
      @repairCrossZone(@currentBox) unless @validateZone(@currentBox)
      @flash = flash
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

      @rivetsBinderCurrentBox.unbind()
      @rivetsBinderCurrentBox = rivets.bind $('.currentBox'),{currentBox: @otherCurrentBox}
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
      pallet = params.pallet
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

      color_coordinate =
        red:    67
        green:  123
        blue:   188

      @palletZone = 
          bound:
            top:      margin * @ratio  # y
            bottom:   (margin + longerEdge) * @ratio # y + height
            left:     margin * @ratio # x
            right:    (margin + shorterEdge) * @ratio # x + width 

      coordinateOriginPoint = 
        x: @palletZone.bound.left
        y: @palletZone.bound.bottom 
      xLine = new Kinetic.Line(
        points: [
          coordinateOriginPoint.x
          coordinateOriginPoint.y
          @palletZone.bound.right * 0.2
          coordinateOriginPoint.y
          @palletZone.bound.right * 0.2 - 15
          coordinateOriginPoint.y - 3
          @palletZone.bound.right * 0.2
          coordinateOriginPoint.y
          @palletZone.bound.right * 0.2 -15
          coordinateOriginPoint.y + 3
        ]
        strokeRed:    color_coordinate.red
        strokeGreen:  color_coordinate.green
        strokeBlue:   color_coordinate.blue
        strokeWidth: 2
        lineCap: "round"
        lineJoin: "round"
      )

      xLabel = new Kinetic.Text(
          x:  @palletZone.bound.right * 0.2 
          y:  coordinateOriginPoint.y - 5
          fontSize:     13
          fontFamily:   "Calibri"
          fill:         "blue"
          text:         'X'
        )
      yLine = new Kinetic.Line(
        points: [
          coordinateOriginPoint.x - 3
          @palletZone.bound.top + @palletZone.bound.bottom * 0.82 + 15
          coordinateOriginPoint.x
          @palletZone.bound.top + @palletZone.bound.bottom * 0.82
          coordinateOriginPoint.x + 3
          @palletZone.bound.top + @palletZone.bound.bottom * 0.82 + 15
          coordinateOriginPoint.x
          @palletZone.bound.top + @palletZone.bound.bottom * 0.82
          coordinateOriginPoint.x
          coordinateOriginPoint.y
        ]
        strokeRed:    color_coordinate.red
        strokeGreen:  color_coordinate.green
        strokeBlue:   color_coordinate.blue
        strokeWidth: 2
        lineCap: "round"
        lineJoin: "round"
      )
      yLabel = new Kinetic.Text(
          x:      coordinateOriginPoint.x - 2
          y:      @palletZone.bound.top + @palletZone.bound.bottom * 0.82 - 15
          fontSize:     13
          fontFamily:   "Calibri"
          fill:         "blue"
          text:         'Y'
          # scaleX:       -1
        )

      @layer.add stageBackground
      @layer.add palletBackground
      @layer.add overhangBackground
      @layer.add xLine
      @layer.add yLine
      @layer.add xLabel
      @layer.add yLabel

      @stage.add @layer

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

      boxes_params = {layer: @layer, zone: @zone, box: boxByRatio, color: params.color, ratio: @ratio, palletOverhang: pallet.overhang }
      boxes_params.knob = params.knob
      @boxes = new Boxes(boxes_params)
      @boxes.shift()


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
          red:    79
          green:  130
          blue:   246
          alpha:  0.8
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
            red:    108
            green:  153
            blue:   57
            alpha:  1
            stroke:
              red:    72
              green:  82
              blue:   38
              alpha:  0.5
          outer:
            red:    0
            green:  0
            blue:   0
            alpha:  0
            stroke:
              red:    70
              green:  186
              blue:   3
              alpha:  0.5

  # dial
  # vectorKnob = $(".dial").knob
  #   min: 0
  #   max: 360
  #   cursor: 8
  #   width: 40
  #   height: 40
  #   thickness: 0.3
  #   skin: 'tron'
  #   font: "10px"
  #   fgColor: "#ff8703"
  #   bgColor: 'black'
  #   displayPrevious: true
  #   displayInput:   false
  #   step: "45"

  #   draw: ->
      
  #     # "tron" case
  #     if @$.data("skin") is "tron"
  #       @cursorExt = 0.3
  #       a = @arc(@cv) # Arc
  #       pa = undefined
  #       # Previous arc
  #       r = 1
  #       @g.lineWidth = @lineWidth
  #       if @o.displayPrevious
  #         pa = @arc(@v)
  #         @g.beginPath()
  #         @g.strokeStyle = @pColor
  #         @g.arc @xy, @xy, @radius - @lineWidth, pa.s, pa.e, pa.d
  #         @g.stroke()
  #       @g.beginPath()
  #       @g.strokeStyle = (if r then @o.fgColor else @fgColor)
  #       @g.arc @xy, @xy, @radius - @lineWidth, a.s, a.e, a.d
  #       @g.stroke()
  #       @g.lineWidth = 2
  #       @g.beginPath()
  #       @g.strokeStyle = @o.fgColor
  #       @g.arc @xy, @xy, @radius - @lineWidth + 1 + @lineWidth * 2 / 3, 0, 2 * Math.PI, false
  #       @g.stroke()
  #       false

  # unit: cm
  pallet =  
    width:    200
    height:   250 
    overhang: 10
  box  =      
    x:      0 
    y:      0
    width:  60  
    height: 20  
    minDistance: 10
      
  params = 
    pallet: pallet
    box: box
    stage: canvasStage
    color: color
    # knob:  vectorKnob

  ################


  @board = new StackBoard(params)

  rivets.formatters.suffix_cm = (value) ->
     "#{Math.abs(value.toFixed(0))}"

  rivets.formatters.availableNewTitle = (value) ->
    "#{value + 100}"

  $("input").prop "readonly", true


  # vector degree
  $("input.dial").prop "readonly", false



  $("#hide_button").click ->
    $("#right_board").animate
      marginLeft: "-100%"
    , 1000, ->
      $("#right_board").hide()
    return

  $("#show_button").click ->
    $("#right_board").show()
    $("#right_board").animate
      marginLeft: "20%"
    , 1000
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



