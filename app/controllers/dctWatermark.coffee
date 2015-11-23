multipart = require 'connect-multiparty'
tmp = require 'tmp'
stenography = require '../models/stenography'
fs = require 'fs'

module.exports = (app) ->
	app.get '/', (req, res) ->
		res.render 'dctWatermark'

	app.get '/dctWatermark', (req, res) ->
		res.render 'dctWatermark'

	app.post '/dctWatermark/run', multipart(), (req, res)->
		tmp.tmpName {template: '/tmp/tmp-XXXXXX.png'}, (_, tmpName)->
			colorFile = if req.files.color then req.files.color.path else __dirname + '/../../public/img/color.png'
			watermarkFile = if req.files.watermark then req.files.watermark.path else __dirname + '/../../public/img/watermark.png'

			stenography.dctWatermark colorFile, watermarkFile, tmpName, req.body.slice, req.body.shift, ->
				res.json {location: tmpName}

				cleanup()
				setTimeout ->
					fs.unlink tmpName, (ex)->
						console.error(ex) if ex
				, 1800000
			, (error)->
				res.status(500)
				res.json(error)
				cleanup()

		cleanup = ->
			for name, file of req.files
				fs.unlink(file.path)
