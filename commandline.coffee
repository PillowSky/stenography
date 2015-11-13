"use strict"

stenography = require './stenography'

#stenography.suffixWatermarking('landscape.png', 'morning.png', 'watermarked.png')
#stenography.suffixDetection('watermarked.png', 'watermark.png')
stenography.dctWatermarking('landscape.png', 'morning.png', 'watermarked.png')
