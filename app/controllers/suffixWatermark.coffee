multipart = require 'connect-multiparty'
tmp = require 'tmp'
stenography = require '../models/stenography'
fs = require 'fs'

module.exports = (app) ->
	app.get '/suffixWatermark', (req, res) ->
		res.render 'suffixWatermark'

	app.post '/suffixWatermark/run', multipart(), (req, res)->
		tmp.tmpName {template: '/tmp/tmp-XXXXXX.png'}, (_, tmpName)->
			colorFile = if req.files.color then req.files.color.path else __dirname + '/../../public/img/color.png'
			watermarkFile = if req.files.watermark then req.files.watermark.path else __dirname + '/../../public/img/watermark.png'

			stenography.suffixWatermark colorFile, watermarkFile, tmpName, req.body.suffix, ->
				res.json {location: tmpName}

				fs.unlink(file.path) for file in req.files
				setTimeout ->
					fs.unlink tmpName, (ex)->
						console.error(ex) if ex
				, 1800000
			, (error)->
				res.status(500)
				res.json(error)
				fs.unlink(file.path) for file in req.files
