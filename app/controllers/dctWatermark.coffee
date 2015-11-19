express  = require 'express'

router = express.Router()

router.get '/', (req, res) ->
	res.render 'dctWatermark'

router.post '/start', (req, res)->
	res.end()

module.exports = (app) ->
	app.use '/', router
	app.use '/dctWatermark', router
