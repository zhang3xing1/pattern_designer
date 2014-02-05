# Dashboard

# class Dashboard
#   constructor: ->

#   move: (meters) ->
#     alert @name + " moved #{meters}m."



# Canvas

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
console.log(rect.x(50))

# add the shape to the layer
layer.add rect

# add the layer to the stage
stage.add layer

class Rabbit
  constructor: (@adjective) ->
  speak: (line) ->
    console.log "The #{@adjective} rabbit says '#{line}'"
 
whiteRabbit = new Rabbit "white"
fatRabbit = new Rabbit "fat"
 
whiteRabbit.speak "Hurry!"
fatRabbit.speak "Tasty"
