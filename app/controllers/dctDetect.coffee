express  = require 'express'

router = express.Router()

router.get '/', (req, res, next) ->
	res.render 'dctdetect'

module.exports = (app) ->
	app.use '/dctDetect', router
