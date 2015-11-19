express  = require 'express'

router = express.Router()
router.get '/', (req, res, next) ->
	res.render 'suffixDetect'

module.exports = (app) ->
	app.use '/suffixDetect', router
