Params

1. stackboard
	input: 	
			box's overlang size
			stackboard layer's width and height(make width < height,so use UI space more)
	output: 
			stackboard's userdefined coordiance
			*stackboard offest of canvas coordiance*
2. box
	input: 
			box's size(width and height)
	output: 
			convert box'size fit stackboard coordiance.


Lint:

	scale: set context.scaleY => -1
		   set text.scaleY => -1 

overhang 是box内边框的限制

绘图区域


