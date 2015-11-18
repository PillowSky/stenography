'use strict'

module.exports = (width, height, count, callback)->
	inAngle = 45
	reAngle = -135

	inRow = 0
	inCol = 0

	reCol = width - 1
	reRow = height - 1

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

	reMove = (angle)->
		switch angle
			when 180
				reRow--
			when 90
				reCol--
			when 45
				reCol--
				reRow++
			when -135
				reCol++
				reRow--

	for _ in [0...count]
		callback(inRow, inCol, reRow, reCol)

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
			when -90
				if inCol == 0
					inAngle = 45
				else
					if inCol == width - 1
						inAngle = -135
			when -135
				if inCol - 1 < 0
					inAngle = -90
				if inRow + 1 >= height
					inAngle = 0

		inMove(inAngle)

		switch reAngle
			when 180
				if reCol == 0
					reAngle = -135
				else
					if reCol == height - 1
						reAngle = 45
			when 90
				if reRow == 0
					reAngle = 45
				else
					if reRow == width - 1
						reAngle = -135
			when 45
				if reRow + 1 >= width
					reAngle = 90
				if reCol - 1 < 0
					reAngle = 180
			when -135
				if reCol + 1 >= height
					reAngle = 180
				if reRow - 1 < 0
					reAngle = 90

		reMove(reAngle)
