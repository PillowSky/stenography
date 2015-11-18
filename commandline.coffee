'use strict'

stenography = require './stenography'

#stenography.suffixWatermark('field.png', 'forest.png', 'watermarked.png', 2)
#stenography.suffixDetect('watermarked.png', 'watermark.png', 2)
#stenography.dctWatermark('field.png', 'forest.png', 'watermarked.png', 2, 8)
stenography.dctDetect('watermarked.png', 'watermark.png', 2, 8)
