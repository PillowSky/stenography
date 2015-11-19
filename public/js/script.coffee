'use strict'

$ ->
	path = window.location.pathname
	path = '/dctWatermark' if path == '/'
	$("a[href='#{path}']").parent().addClass('active')

	sliceValue = $('#sliceValue')
	shiftValue = $('#shiftValue')
	$('#slice').slider().on 'slide', (slider)->
		sliceValue.text(slider.value)
	$('#shift').slider().on 'slide', (slider)->
		shiftValue.text(slider.value)

	$('#color img').click ->
		$('#color input').click()

	$('#watermark img').click ->
		$('#watermark input').click()

	colorFile = null
	watermarkFile = null
	previewColor = (file)->
		colorFile = file
		reader = new FileReader()
		reader.onload = (event) ->
			$('#color img').attr('src', event.target.result)
		reader.readAsDataURL(file)

	previewWatermark = (file)->
		watermarkFile = file
		reader = new FileReader()
		reader.onload = (event) ->
			$('#watermark img').attr('src', event.target.result)
		reader.readAsDataURL(file)

	$('#color input').change ->
		previewColor(@files[0]) if @files.length

	$('#watermark input').change ->
		previewWatermark(@files[0]) if @files.length

	$('.dropable').on 'dragenter', (event)->
		$(this).addClass('dragover')

	$('.dropable').on 'dragleave', (event)->
		$(this).removeClass('dragover')

	$('.dropable').on 'dragover', (event)->
		event.preventDefault()

	$('#color').on 'drop', (event)->
		event.preventDefault()
		$(this).removeClass('dragover')
		files = event.originalEvent.dataTransfer.files
		previewColor(files[0]) if files.length

	$('#watermark').on 'drop', (event)->
		event.preventDefault()
		$(this).removeClass('dragover')
		files = event.originalEvent.dataTransfer.files
		previewWatermark(files[0]) if files.length

	$('#start').on 'click', (event)->
		form = new FormData()
		form.append('slice', $('#slice').slider('getValue'))
		form.append('shift', $('#shift').slider('getValue'))
		form.append('color', colorFile)
		form.append('watermark', watermarkFile)
		xhr = new XMLHttpRequest()
		xhr.open('post', '/dctWatermark/start')
		xhr.onload = ->
			console.log 'onload'
		xhr.onerror = ->
			console.log 'onerror'
		xhr.send(form)
