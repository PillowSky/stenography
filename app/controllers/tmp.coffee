module.exports = (app) ->
	app.get '/tmp/:filename', (req, res) ->
		res.sendfile("/tmp/#{req.params.filename}")
