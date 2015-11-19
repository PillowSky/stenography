express  = require 'express'
multipart = require('connect-multiparty')()
tmp = require('tmp')
stenography = require '../models/stenography'

router = express.Router()

router.get '/', (req, res) ->
	res.render 'dctWatermark'

router.post '/start', multipart, (req, res)->
	tmp.tmpName {template: '/tmp/tmp-XXXXXX.png'}, (error, tmpName)->
		throw error if error

		colorFile = req.files.color.path || 'public/img/color.png'
		watermarkFile = req.files.color.path || 'public/img/watermark.png'
		stenography.dctWatermark colorFile, watermarkFile, tmpName, req.body.slice, req.body.shift, ->
			res.json {location: tmpName}

module.exports = (app) ->
	app.use '/', router
	app.use '/dctWatermark', router
