multipart = require 'connect-multiparty'
tmp = require 'tmp'
stenography = require '../models/stenography'
fs = require 'fs'

module.exports = (app) ->
	app.get '/dctDetect', (req, res) ->
		res.render 'dctDetect'

	app.post '/dctDetect/run', multipart(), (req, res)->
		tmp.tmpName {template: '/tmp/tmp-XXXXXX.png'}, (_, tmpName)->
			watermakedFile = if req.files.watermarked then req.files.watermarked.path else __dirname + '/../../public/img/dctWatermarked.png'

			stenography.dctDetect watermakedFile, tmpName, req.body.slice, req.body.shift, ->
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
