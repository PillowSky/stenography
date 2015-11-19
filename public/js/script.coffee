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
		button = $(this)
		elapsed = 0
		button.prop('disabled', true).text('Running')

		handle = setInterval ->
			elapsed++
			button.text("Running #{elapsed}s")
		, 1000

		form = new FormData()
		form.append('slice', $('#slice').slider('getValue'))
		form.append('shift', $('#shift').slider('getValue'))
		form.append('color', colorFile)
		form.append('watermark', watermarkFile)

		xhr = new XMLHttpRequest()
		xhr.open('post', '/dctWatermark/run')

		xhr.onload = ->
			clearInterval(handle)
			location = JSON.parse(this.responseText).location
			$('#result img').attr('src', location)
			$('#result a').attr('href', location)
			$('#result').slideDown()
			button.prop('disabled', false).text('Start DCT Watermarking')

		xhr.onerror = (event)->
			clearInterval(handle)
			console.error(event)
			alert("Error: #{JSON.stringify(event)}")
			button.prop('disabled', false).text('Start DCT Watermarking')

		xhr.send(form)
