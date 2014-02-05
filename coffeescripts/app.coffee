class Box extends Backbone.Model
  initialize: -> 
    @on('change:price change:quantity', @setSubtotal)
    @on('change:item', @setPrice)
  defaults: {
    x_position: 0,
    y_position: 0,
    rotate:     0
  },
  setXPosition: ->
  setYPosition: ->
  setRotate: ->
  delete: ->

class @Boxes extends Backbone.Collection
  model: Box,
  size: 0,
  initialize: ->

# test
# BINDING BACKBONE.JS MODEL(S) TO A VIEW
user = new Backbone.Model(name: "Joe")
el = document.getElementById("user-view")
rivets.bind el,
  user: user


# Canvas test

stage = new Kinetic.Stage(
  container: "canvas_container"
  width: 300  
  height: 360
)
layer = new Kinetic.Layer()
rect = new Kinetic.Rect(
  x: 10
  y: 10
  width: 20
  height: 20
  fill: "green"
  strokeWidth: 4
)

# add the shape to the layer
layer.add rect

# add the layer to the stage
stage.add layer



