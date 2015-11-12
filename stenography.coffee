opencv = require 'opencv'
async = require 'async'

module.exports.suffixWatermarking = (imageFile, watermarkFile, watermarkedFile)->
	async.parallel
		image: (callback)->
			opencv.readImage(imageFile, callback)
		watermark: (callback)->
			opencv.readImage(watermarkFile, callback)
	, (error, results)->
			width = results.image.width()
			height = results.image.height()
			buffer = Buffer(width * height * 3)

			index = 0
			for i in [0...width]
				for j in [0...height]
					image = results.image.pixel(i, j)
					watermark = results.watermark.pixel(i, j)
					watermark.
					buffer[index++] = (image[0] & 252) | watermark[0] >> 6
					buffer[index++] = (image[1] & 252) | watermark[1] >> 6
					buffer[index++] = (image[2] & 252) | watermark[2] >> 6

			console.log('OK', index)
			watermarked = new opencv.Matrix(height, width, opencv.Constants.CV_8UC3);
			watermarked.put(buffer)
			watermarked.save(watermarkedFile);

			'''
			#for i in [0...results[.row]
			#	for j in [0...results[0].col]
			#console.log results[0].pixel(500, 500)
			
			
			height = results.image.height()
			width = results.image.width()
			watermarked = new opencv.Matrix(height, width)

			#for col in [0...width]
			#	for row in [0...height]
					
			console.log Array.isArray(results.image.pixel(0, 0))
			for key, value of results.image.pixel(0, 0)
				console.log(key, value)

			#typeary = new Uint8Array.from(results.image.pixel(0, 0))
			#console.log(typeary)
			ab = new ArrayBuffer(32);
			i32 = new Uint8Array(ab, 4, 2);
			i33 = new Uint8Array(32); 
			#console.log(i32)
			console.log Array.isArray(i32)
			#for key, value of i33
			#	console.log(key)
			
			'''


module.exports.suffixDetection = (watermarkedFile, watermarkFile)->
	opencv.readImage watermarkedFile, (error, watermarked)->
		width = watermarked.width()
		height = watermarked.height()
		buffer = Buffer(width * height * 3)

		index = 0
		for i in [0...width]
			for j in [0...height]
				image = watermarked.pixel(i, j)
				buffer[index++] = (image[0] & 3) << 6
				buffer[index++] = (image[1] & 3) << 6
				buffer[index++] = (image[2] & 3) << 6
				#console.log(image[2], image[2] & 15, (image[2] & 15) << 4)

		console.log('OK', index)
		watermark = new opencv.Matrix(height, width, opencv.Constants.CV_8UC3);
		watermark.put(buffer)
		watermark.save(watermarkFile);
