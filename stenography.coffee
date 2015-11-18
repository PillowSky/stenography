"use strict"

jimp = require 'jimp'
async = require 'async'
dct = require './dct'

module.exports.suffixWatermarking = (colorFile, watermarkFile, watermarkedFile)->
	async.parallel
		color: (callback)->
			jimp.read(colorFile, callback)
		watermark: (callback)->
			jimp.read(watermarkFile, callback)
	, (error, results)->
		width = results.color.bitmap.width
		height = results.color.bitmap.height
		color = results.color.bitmap.data
		watermark = results.watermark.bitmap.data
		length = color.length
		watermarked = new Uint8ClampedArray(length)

		for pixel in [0...length] by 4
			for i in [pixel...pixel+4]
				watermarked[i] = (color[i] & 252) | watermark[i] >> 6

		new jimp width, height, (error, watermarkedImage)->
			watermarkedImage.bitmap.data = watermarked
			watermarkedImage.opaque().quality(100).write watermarkedFile, ->
				console.log 'Done'

module.exports.suffixDetection = (watermarkedFile, watermarkFile)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		width = watermarkedImage.bitmap.width
		height = watermarkedImage.bitmap.height
		watermarked = watermarkedImage.bitmap.data
		length = watermarked.length
		watermark = new Uint8ClampedArray(length)

		for pixel in [0...length] by 4
			for i in [pixel...pixel+4]
				watermark[i] = (watermarked[i] & 3) << 6

		new jimp width, height, (error, watermarkImage)->
			watermarkImage.bitmap.data = watermark
			watermarkImage.opaque().quality(100).write watermarkFile, ->
				console.log 'Done'

zigzag = (width, height, count, callback)->
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

module.exports.dctWatermarking = (colorFile, watermarkFile, watermarkedFile)->
	async.parallel
		color: (callback)->
			jimp.read(colorFile, callback)
		watermark: (callback)->
			jimp.read(watermarkFile, callback)
	, (error, results)->
		width = results.color.bitmap.width
		height = results.color.bitmap.height

		colorDct = dct.dct2(results.color.bitmap.data, width, height)
		watermarkDct = dct.dct2(results.watermark.bitmap.data, width, height)

		'''
		for pixel in [0...width * height * 4] by 4
			for i in [pixel...pixel+3]
				colorDct[i] = colorDct[i] & 0xFFFF0000
				#colorDct[i] = (colorDct[i] & 0xFFFF0000) | watermarkDct[i] >> 1
		'''

		zigzag width, height, 1024 * 1024 / 2, (inRow, inCol, reRow, reCol)->
			colorDct[(reRow * width + reCol) * 4] = watermarkDct[(inRow * width + inCol) * 4] >> 8
			colorDct[(reRow * width + reCol) * 4 + 1] = watermarkDct[(inRow * width + inCol) * 4 + 1] >> 8
			colorDct[(reRow * width + reCol) * 4 + 2] = watermarkDct[(inRow * width + inCol) * 4 + 2] >> 8

		watermarkedIct = dct.ict2(colorDct, width, height)

		new jimp width, height, (error, watermarkedImage)->
			watermarkedImage.bitmap.data = new Uint8ClampedArray(watermarkedIct)
			watermarkedImage.opaque().quality(100).write watermarkedFile, ->
				console.log 'Done'


module.exports.dctDetection = (watermarkedFile, watermarkFile)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		width = watermarkedImage.bitmap.width
		height = watermarkedImage.bitmap.height

		watermarkedDct = dct.dct2(watermarkedImage.bitmap.data, width, height)
		watermarkDct = new Float64Array(width * height * 4)

		zigzag width, height, 1024 * 1024 / 2, (inRow, inCol, reRow, reCol)->
			watermarkDct[(inRow * width + inCol) * 4] = watermarkedDct[(reRow * width + reCol) * 4] << 8
			watermarkDct[(inRow * width + inCol) * 4 + 1] = watermarkedDct[(reRow * width + reCol) * 4 + 1] << 8
			watermarkDct[(inRow * width + inCol) * 4 + 2] = watermarkedDct[(reRow * width + reCol) * 4 + 2] << 8

		watermarkIct = dct.ict2(watermarkDct, width, height)

		new jimp width, height, (error, watermarkImage)->
			watermarkImage.bitmap.data = new Uint8ClampedArray(watermarkIct)
			watermarkImage.opaque().quality(100).write watermarkFile, ->
				console.log 'Done'
