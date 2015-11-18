'use strict'

jimp = require 'jimp'
async = require 'async'
dct = require './dct'
zigzag = require './zigzag'

module.exports.suffixWatermark = (colorFile, watermarkFile, watermarkedFile, suffix)->
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
		shift = 8 - suffix
		andNumber = (1 << 8) - (1 << suffix)
		watermarked = new Uint8ClampedArray(length)

		for pixel in [0...length] by 4
			for i in [pixel...pixel+4]
				watermarked[i] = (color[i] & andNumber) | watermark[i] >> shift

		new jimp width, height, (error, watermarkedImage)->
			watermarkedImage.bitmap.data = watermarked
			watermarkedImage.opaque().quality(100).write watermarkedFile, ->
				console.log 'Done'

module.exports.suffixDetect = (watermarkedFile, watermarkFile, suffix)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		width = watermarkedImage.bitmap.width
		height = watermarkedImage.bitmap.height
		watermarked = watermarkedImage.bitmap.data
		length = watermarked.length
		shift = 8 - suffix
		andNumber = (1 << suffix) - 1
		watermark = new Uint8ClampedArray(length)

		for pixel in [0...length] by 4
			for i in [pixel...pixel+4]
				watermark[i] = (watermarked[i] & andNumber) << shift

		new jimp width, height, (error, watermarkImage)->
			watermarkImage.bitmap.data = watermark
			watermarkImage.opaque().quality(100).write watermarkFile, ->
				console.log 'Done'

module.exports.dctWatermark = (colorFile, watermarkFile, watermarkedFile, slice, shift)->
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

		zigzag width, height, width * height / slice, (inRow, inCol, reRow, reCol)->
			colorDct[(reRow * width + reCol) * 4] = watermarkDct[(inRow * width + inCol) * 4] >> shift
			colorDct[(reRow * width + reCol) * 4 + 1] = watermarkDct[(inRow * width + inCol) * 4 + 1] >> shift
			colorDct[(reRow * width + reCol) * 4 + 2] = watermarkDct[(inRow * width + inCol) * 4 + 2] >> shift

		watermarkedIct = dct.ict2(colorDct, width, height)

		new jimp width, height, (error, watermarkedImage)->
			watermarkedImage.bitmap.data = new Uint8ClampedArray(watermarkedIct)
			watermarkedImage.opaque().quality(100).write watermarkedFile, ->
				console.log 'Done'


module.exports.dctDetect = (watermarkedFile, watermarkFile, slice, shift)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		width = watermarkedImage.bitmap.width
		height = watermarkedImage.bitmap.height

		watermarkedDct = dct.dct2(watermarkedImage.bitmap.data, width, height)
		watermarkDct = new Float64Array(width * height * 4)

		zigzag width, height, width * height / slice, (inRow, inCol, reRow, reCol)->
			watermarkDct[(inRow * width + inCol) * 4] = watermarkedDct[(reRow * width + reCol) * 4] << shift
			watermarkDct[(inRow * width + inCol) * 4 + 1] = watermarkedDct[(reRow * width + reCol) * 4 + 1] << shift
			watermarkDct[(inRow * width + inCol) * 4 + 2] = watermarkedDct[(reRow * width + reCol) * 4 + 2] << shift

		watermarkIct = dct.ict2(watermarkDct, width, height)

		new jimp width, height, (error, watermarkImage)->
			watermarkImage.bitmap.data = new Uint8ClampedArray(watermarkIct)
			watermarkImage.opaque().quality(100).write watermarkFile, ->
				console.log 'Done'
