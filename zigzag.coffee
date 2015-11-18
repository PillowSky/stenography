"use strict"

width = 5
height = 5
size = width * height
data = [0...size]

inAngle = 45
inRow = 0
inCol = 0

# angle, the angle has walked

inMove = (angle)->
	switch angle
		when 45
			inRow--
			inCol++
		when 0
			inCol++
		when -90
			inRow++
		when -135
			inRow++
			inCol--

for _ in [0...size]
	console.log("(#{inRow}, #{inCol}) => #{data[inRow * width + inCol]}")

	switch inAngle
		when 45
			if inRow - 1 < 0
				inAngle = 0
			if inCol + 1 >= width
				inAngle = -90

		when 0
			if inRow == 0
				inAngle = -135
			else
				if inRow == height - 1
					inAngle = 45
				else
					throw new Exception('Error 0')

		when -90
			if inCol == 0
				inAngle = 45
			else
				if inCol == width - 1
					inAngle = -135
				else
					throw new Exception('Error -90')

		when -135
			if inCol - 1 < 0
				inAngle = -90

			if inRow + 1 >= height
				inAngle = 0

	inMove(inAngle)
