$ = require 'jquery'
core = require './core'

class BaseMod
	constructor: (mark, modName, contentDom, args, opt, onFirstRender) ->
		@_mark = mark
		@_modName = modName
		if not contentDom
			return @
		@_contentDom = contentDom
		@_bindEvents()
		@_args = args || []
		@_opt = opt || {}
		@_onFirstRender = onFirstRender
		@_argMap = @_getArgMap @_args
		@init()
		@render()

	viewed = false
	showNavTab: false
	argsPattern: ''
	navTab: ''
	events: {}
	parentModNames:
		'home': 1

	_bindEvents: ->
		$.each @events, (k, v) =>
			k = k.split ' '
			@_contentDom.on k.shift(), k.join(' '), @[v]

	_unbindEvents: ->
		$.each @events, (k, v) =>
			k = k.split ' '
			@_contentDom.off k.shift(), k.join(' '), @[v]

	_getArgMap: (args) ->
		res = {}
		if @argsPattern
			args = @_args
			keys = @argsPattern.replace(/^\/+/, '').split '/'
			for key, i in keys
				res[key] = args[i] || '' if key
		res

	_ifNotCachable: (relModName, callback, elseCallback) ->
		cachable = if typeof @cachable isnt 'undefined' then @cachable else core.modCacheable()
		if typeof cachable isnt 'undefined'
			if cachable
				elseCallback?()
			else
				callback?()
		else
			relModInst = core.getCached(relModName)
			if relModInst
				if not relModInst.hasParent @_modName
					callback?()
				else
					elseCallback?()
			else
				require ['mod/' + relModName + '/main'], (ModClass) =>
					relModInst = new ModClass relModName
					if not relModInst.hasParent @_modName
						callback?()
					else
						elseCallback?()
				, =>
					if relModName.indexOf(@_modName + '/') isnt 0
						callback?()
					else
						elseCallback?()

	_afterFadeIn: (relModInst) ->
		@viewed = true

	_afterFadeOut: (relModName) ->
		@_ifNotCachable relModName, =>
			@destroy()

	_renderHeader: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .sb-mod__header', @_contentDom).html data
			else
				$('> .sb-mod__header', @_contentDom).html @_headerTpl.render data

	_renderBody: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .sb-mod__body', @_contentDom).html data
			else
				$('> .sb-mod__body', @_contentDom).html @_bodyTpl.render data

	_renderFixedFooter: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .sb-mod__fixed-footer', @_contentDom).html(data).show()
			else
				$('> .sb-mod__fixed-footer', @_contentDom).html(@_fixedFooterTpl.render data).show()

	_renderError: (msg) ->
		if @_contentDom
			$('> .sb-mod__body', @_contentDom).html [
				'<div class="sb-mod__body__msg" data-refresh-btn>'
					'<div class="msg">'
						msg or G.SVR_ERR_MSG
					'</div>'
					'<div class="refresh"><span class="icon icon-refresh"></span>点击刷新</div>'
				'</div>'
			].join ''
			$('> .sb-mod__fixed-footer', @_contentDom).hide()

	_onRender: ->
		@_onFirstRender?()
		@_onFirstRender = null

	render: ->
		if @_headerTpl
			@_renderHeader
				args: @_args
				opt: @_opt
		if @_bodyTpl
			@_renderBody
				args: @_args
				opt: @_opt
		if @_fixedFooterTpl
			@_renderFixedFooter
				args: @_args
				opt: @_opt
		@_onRender()

	init: ->

	$: (s) ->
		$ s, @_contentDom

	getMark: ->
		@_mark

	getModName: ->
		@_modName

	getArgs: ->
		@_args

	getArgMap: ->
		@_argMap

	getMarkWithArgs: (args) ->
		'view/' + @_modName + '/-/' + args.join('/')

	getMarkWithArgMap: (argMap = {}) ->
		keys = @argsPattern.replace(/^\/+/, '').split '/'
		for key, i in keys
			keys[i] = argMap[key] || ''
		if keys.length
			'view/' + @_modName + '/-/' + keys.join('/')
		else
			'view/' + @_modName

	update: (mark, args, opt) ->
		@_mark = mark
		@_args = args || @_args
		@_opt = opt || @_opt
		@_argMap = @_getArgMap @_args
		@refresh()

	refresh: ->
		@scrollToTop()
		core.scroll 0
		@render()

	scrollToTop: ->
		$('> .sb-mod__body', @_contentDom).scrollTop 0

	isRenderred: ->
		$('[data-sb-mod-not-renderred]', @_contentDom).length is 0

	hasParent: (modName) ->
		res = @_modName.indexOf(modName + '/') is 0
		if not res
			for k, v of @parentModNames
				res = modName is k or k.indexOf(modName + '/') is 0
				break if res
		res

	fadeIn: (relModInst, animateType, cb) ->
		core.fadeIn @, @_contentDom, relModInst?.hasParent(@_modName), animateType, =>
			@_afterFadeIn relModInst
			cb?()

	fadeOut: (relModName, animateType, cb) ->
		@_contentDom.attr 'data-sb-scene', (parseInt(@_contentDom.attr('data-sb-scene')) or 0) + 1
		@_ifNotCachable relModName, =>
			core.removeCache @_modName
		core.fadeOut @, @_contentDom, @hasParent(relModName), animateType, =>
			@_afterFadeOut relModName
			cb?()

	captureScene: (callback) ->
		if @_contentDom
			scene = parseInt(@_contentDom.attr('data-sb-scene')) or 0
			callback (callback) =>
				if @_contentDom
					newScene = parseInt(@_contentDom.attr('data-sb-scene')) or 0
					callback() if newScene is scene

	destroy: () ->
		core.removeCache @_modName
		@_unbindEvents()
		@_contentDom.remove()
		@_contentDom = null

module.exports = BaseMod
