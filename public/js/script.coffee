'use strict'

$ ->
	path = window.location.pathname
	path = 'dctWatermark' if path == '/'
	$("a[href='#{path}']").parent().addClass('active')
