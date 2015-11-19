'use strict'

jimp = require 'jimp'
async = require 'async'
dct = require './dct'
zigzag = require './zigzag'

module.exports.suffixWatermark = (colorFile, watermarkFile, watermarkedFile, suffix, done, fail)->
	async.parallel
		color: (callback)->
			jimp.read(colorFile, callback)
		watermark: (callback)->
			jimp.read(watermarkFile, callback)
	, (error, results)->
		return fail(error) if error

		width = results.color.bitmap.width
		height = results.color.bitmap.height
		color = results.color.bitmap.data
		watermark = results.watermark.resize(width, height).bitmap.data
		length = color.length
		shift = 8 - suffix
		andNumber = (1 << 8) - (1 << suffix)
		watermarked = new Uint8ClampedArray(length)

		for pixel in [0...length] by 4
			for i in [pixel...pixel+4]
				watermarked[i] = (color[i] & andNumber) | watermark[i] >> shift

		new jimp width, height, (error, watermarkedImage)->
			watermarkedImage.bitmap.data = watermarked
			watermarkedImage.opaque().quality(100).write watermarkedFile, done

module.exports.suffixDetect = (watermarkedFile, watermarkFile, suffix, done, fail)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		return fail(error) if error

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
			watermarkImage.opaque().quality(100).write watermarkFile, done

module.exports.dctWatermark = (colorFile, watermarkFile, watermarkedFile, slice, shift, done, fail)->
	async.parallel
		color: (callback)->
			jimp.read(colorFile, callback)
		watermark: (callback)->
			jimp.read(watermarkFile, callback)
	, (error, results)->
		return fail(error) if error

		width = results.color.bitmap.width
		height = results.color.bitmap.height

		colorDct = dct.dct2(results.color.bitmap.data, width, height)
		watermarkDct = dct.dct2(results.watermark.resize(width, height).bitmap.data, width, height)

		zigzag width, height, width * height / slice, (inRow, inCol, reRow, reCol)->
			inIndex = (inRow * width + inCol) * 4
			reIndex = (reRow * width + reCol) * 4
			colorDct[reIndex++] = watermarkDct[inIndex++] >> shift
			colorDct[reIndex++] = watermarkDct[inIndex++] >> shift
			colorDct[reIndex] = watermarkDct[inIndex] >> shift

		watermarkedIct = dct.ict2(colorDct, width, height)

		new jimp width, height, (error, watermarkedImage)->
			watermarkedImage.bitmap.data = new Uint8ClampedArray(watermarkedIct)
			watermarkedImage.opaque().quality(100).write watermarkedFile, done

module.exports.dctDetect = (watermarkedFile, watermarkFile, slice, shift, done, fail)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		return fail(error) if error

		width = watermarkedImage.bitmap.width
		height = watermarkedImage.bitmap.height

		watermarkedDct = dct.dct2(watermarkedImage.bitmap.data, width, height)
		watermarkDct = new Float64Array(width * height * 4)

		zigzag width, height, width * height / slice, (inRow, inCol, reRow, reCol)->
			inIndex = (inRow * width + inCol) * 4
			reIndex = (reRow * width + reCol) * 4
			watermarkDct[inIndex++] = watermarkedDct[reIndex++] << shift
			watermarkDct[inIndex++] = watermarkedDct[reIndex++] << shift
			watermarkDct[inIndex] = watermarkedDct[reIndex] << shift

		watermarkIct = dct.ict2(watermarkDct, width, height)

		new jimp width, height, (error, watermarkImage)->
			watermarkImage.bitmap.data = new Uint8ClampedArray(watermarkIct)
			watermarkImage.opaque().quality(100).write watermarkFile, done
