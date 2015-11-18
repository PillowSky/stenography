"use strict"

stenography = require './stenography'

#stenography.suffixWatermarking('field.png', 'forest.png', 'watermarked.png')
#stenography.suffixDetection('watermarked.png', 'watermark.png')
#stenography.dctWatermarking('field.png', 'forest.png', 'watermarked.png')
stenography.dctDetection('watermarked.png', 'watermark.png')
