multipart = require 'connect-multiparty'
tmp = require 'tmp'
stenography = require '../models/stenography'
fs = require 'fs'

module.exports = (app) ->
	app.get '/suffixDetect', (req, res) ->
		res.render 'suffixDetect'

	app.post '/suffixDetect/run', multipart(), (req, res)->
		tmp.tmpName {template: '/tmp/tmp-XXXXXX.png'}, (_, tmpName)->
			watermakedFile = if req.files.watermarked then req.files.watermarked.path else 'public/img/suffixWatermarked.png'

			stenography.suffixDetect watermakedFile, tmpName, req.body.suffix, ->
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
