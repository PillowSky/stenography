express  = require 'express'

router = express.Router()
router.get '/', (req, res) ->
	res.render 'suffixDetect'

module.exports = (app) ->
	app.use '/suffixDetect', router
