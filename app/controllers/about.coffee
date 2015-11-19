express  = require 'express'

router = express.Router()

router.get '/', (req, res) ->
	res.render 'about'

module.exports = (app) ->
	app.use '/about', router
