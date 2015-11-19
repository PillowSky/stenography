express  = require 'express'

router = express.Router()

router.get '/', (req, res) ->
	res.render 'dctDetect'

module.exports = (app) ->
	app.use '/dctDetect', router
