express  = require 'express'

router = express.Router()

router.get '/', (req, res, next) ->
	res.render 'dctWatermark'

module.exports = (app) ->
	app.use '/', router
	app.use '/dctWatermark', router
