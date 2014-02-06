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

class Boxes extends Backbone.Collection
  model: Box,
  
  initialize: ->
    #
    #Canvas
    #
    @stage = new Kinetic.Stage(
      container: "canvas_container"
      width: 300  
      height: 360
    )
    @layer = new Kinetic.Layer()
    @rect = new Kinetic.Rect(
      x: 10
      y: 10
      width: 20
      height: 20
      fill: "green"
      strokeWidth: 4
    )
    # add the shape to the layer
    @layer.add @rect

    # add the layer to the stage
    @stage.add @layer

    #
    # Box
    #
    @newBoxId = 1
    @message = "The new box id will be 1"
  addNewBox: =>
    console.log(@newBoxId)
  flash: =>
    @message


rivets.bind $('.boxes'),{boxes: boxes=new Boxes}



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




