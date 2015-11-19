'use strict'

$ ->
	path = window.location.pathname
	path = '/dctWatermark' if path == '/'
	$("a[href='#{path}']").parent().addClass('active')

	sliderConfig =
		'slice':
			'control': '#slice'
			'value': '#sliceValue'
		'shift':
			'control': '#shift'
			'value': '#shiftValue'
		'suffix':
			'control': '#suffix'
			'value': '#suffixValue'

	$.each sliderConfig, (name, config)->
		if $(config.control).length
			$(config.control).slider().on 'slide', (slider)->
				$(config.value).text(slider.value)

	$('.dropable').on 'dragenter', (event)->
		$(this).addClass 'dragover'

	$('.dropable').on 'dragleave', (event)->
		$(this).removeClass 'dragover'

	$('.dropable').on 'dragover', (event)->
		event.preventDefault()

	previewConfig =
		'color':
			'selector': '#color'
			'img': '#color img'
			'input': '#color input'
		'watermark':
			'selector': '#watermark'
			'img': '#watermark img'
			'input': '#watermark input'
		'watermarked':
			'selector': '#watermarked'
			'img': '#watermarked img'
			'input': '#watermarked input'

	preview = (file, name)->
		previewConfig[name].file = file
		reader = new FileReader()
		reader.onload = (event)->
			$(previewConfig[name].img).attr('src', event.target.result)
		reader.readAsDataURL(file)

	$.each previewConfig, (name, config)->
		if $(config.selector).length
			$(config.img).click ->
				$(config.input).click()

			$(config.input).change ->
				preview(@files[0], name) if @files.length

			$(config.selector).on 'drop', (event)->
				event.preventDefault()
				$(this).removeClass('dragover')
				files = event.originalEvent.dataTransfer.files
				preview(files[0], name) if files.length

	$('#start').on 'click', (event)->
		button = $(this)
		buttonText = button.text()
		button.prop('disabled', true).text('Running 0s')
		$('#result').slideUp()

		elapsed = 0
		handle = setInterval ->
			elapsed++
			button.text("Running #{elapsed}s")
		, 1000

		form = new FormData()
		$.each sliderConfig, (name, config)->
			if $(config.control).length
				form.append(name, $(config.control).slider('getValue'))

		$.each previewConfig, (name, config)->
			if $(config.selector).length
				form.append(name, config.file)

		xhr = new XMLHttpRequest()
		xhr.open('post', "#{path}/run")

		xhr.onload = (event)->
			clearInterval(handle)
			console.log(this, event)

			location = JSON.parse(@responseText).location
			$('#result img').attr('src', location)
			$('#result a').attr('href', location)
			$('#result').slideDown()
			button.prop('disabled', false).text(buttonText)

		xhr.onerror = (event)->
			clearInterval(handle)
			console.error(this, event)

			alert("Error: #{JSON.stringify(event)}")
			button.prop('disabled', false).text(buttonText)

		xhr.send(form)
