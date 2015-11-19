express  = require 'express'

router = express.Router()
router.get '/', (req, res, next) ->
	res.render 'suffixWatermark'

module.exports = (app) ->
	app.use '/suffixWatermark', router
