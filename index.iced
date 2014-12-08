_ = require 'underscore'
https = require 'https'
querystring = require 'querystring'

module.exports = exports = class NoCaptcha

	constructor: (publicKey, privateKey, isSecure) ->
		@PUBLIC_KEY = publicKey
		@PRIVATE_KEY = privateKey
		@IS_SECURE = isSecure? is yes

	toHTML: (options)->
		script_src = "www.google.com/recaptcha/api.js"
		script_src = (if @IS_SECURE then 'https://' else 'http://') + script_src

		div = "<div class='g-recaptcha' data-sitekey='#{@PUBLIC_KEY}'"

		if options?
			external = querystring.stringify _.pick options, ['onload', 'render', 'hl']			
			script_src = script_src+'?'+external

			if options.theme is 'dark' or options.theme is 'light'
				div = div+" data-theme='#{options.theme}'"
			if options.type is 'audio' or options.type is 'image'
				div = div+" data-type='#{options.type}'"
			if options.callback
				div = div+" data-callback='#{options.callback}'"

		div = div + "></div>"
		script = "<script src='#{script_src}' async defer></script>"

		return script+div

	verify: ({response, remoteip}, callback)->
		if not callback
			return new Error 'No callback'

		if not response?
			return callback new Error 'No response'

		if not remoteip?
			return callback new Error 'No remote IP'

		external = querystring.stringify
			secret: @PRIVATE_KEY
			response: response
			remoteip: remoteip

		reqOption = {
			host: 'www.google.com'
			path: '/recaptcha/api/siteverify?'+external
			port: 443
		}

		request = https.get("https://www.google.com/recaptcha/api/siteverify?"+external, (resp)->
			data = ''
			resp.on 'data', (chunk)->
				data += chunk

			resp.on 'end', ()->
				res = JSON.parse data
				if res.success is true
					return callback null, res
				else
					return callback new Error(res['error-codes'] or "Invalide response")
		)
		.on 'error', (err)->
			return callback err








	