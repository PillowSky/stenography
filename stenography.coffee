jimp = require 'jimp'
async = require 'async'

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
			watermarked = Buffer(length)

			for pixel in [0...length] by 4
				for i in [pixel...pixel+4]
					watermarked[i] = (color[i] & 252) | watermark[i] >> 6

			new jimp width, height, (error, watermarkedImage)->
				watermarkedImage.bitmap.data = watermarked
				watermarkedImage.opaque().write watermarkedFile, ->
					console.log 'Done'

module.exports.suffixDetection = (watermarkedFile, watermarkFile)->
	jimp.read watermarkedFile, (error, watermarkedImage)->
		width = watermarkedImage.bitmap.width
		height = watermarkedImage.bitmap.height
		watermarked = watermarkedImage.bitmap.data
		length = watermarked.length
		watermark = Buffer(length)

		for pixel in [0...length] by 4
			for i in [pixel...pixel+4]
				watermark[i] = (watermarked[i] & 3) << 6

		new jimp width, height, (error, watermarkImage)->
			watermarkImage.bitmap.data = watermark
			watermarkImage.opaque().write watermarkFile, ->
				console.log 'Done'

