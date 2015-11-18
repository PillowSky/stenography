'use strict'

stenography = require './stenography'

showUsage = ->
	console.log('Usage:')
	console.log('\tcoffee cmd.coffee suffix watermark <color file> <watermark file> <watermarked file> <suffix>')
	console.log('\tcoffee cmd.coffee suffix detect <watermarked file> <watermark file> <suffix>')
	console.log('\tcoffee cmd.coffee dct watermark <color file> <watermark file> <watermarked file> <slice> <shift>')
	console.log('\tcoffee cmd.coffee dct detect <watermarked file> <watermark file> <slice> <shift>')
	process.exit(-1)

switch process.argv[2]
	when 'suffix'
		switch process.argv[3]
			when 'watermark'
				stenography.suffixWatermark(process.argv[4], process.argv[5], process.argv[6], process.argv[7])
			when 'detect'
				stenography.suffixDetect(process.argv[4], process.argv[5], process.argv[6])
			else
				showUsage()

	when 'dct'
		switch process.argv[3]
			when 'watermark'
				stenography.dctWatermark(process.argv[4], process.argv[5], process.argv[6], process.argv[7], process.argv[8])
			when 'detect'
				stenography.dctDetect(process.argv[4], process.argv[5], process.argv[6], process.argv[7])
			else
				showUsage()
	else
		showUsage()
