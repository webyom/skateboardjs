$ = require 'jquery'
core = require './core'

class BaseMod
	constructor: (mark, modName, contentDom, params, opt, onFirstRender) ->
		@_mark = mark
		@_modName = modName
		if not contentDom
			return @
		@_contentDom = contentDom
		@_bindEvents()
		@_params = params || {}
		@_opt = opt || {}
		@_onFirstRender = onFirstRender
		@init()

	viewed: false
	showNavTab: false
	navTab: ''
	events: {}
	parentModNames:
		'home': 1
	headerTpl: ''
	bodyTpl: ''
	fixedFooterTpl: ''
	ReactComponent: null

	_bindEvents: ->
		for own k, v of @events
			k = k.split ' '
			@_contentDom.on k.shift(), k.join(' '), @[v]

	_unbindEvents: ->
		for own k, v of @events
			k = k.split ' '
			@_contentDom.off k.shift(), k.join(' '), @[v]

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
				$('> .sb-mod__header', @_contentDom).html @headerTpl.render data

	_renderBody: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .sb-mod__body', @_contentDom).html data
			else
				$('> .sb-mod__body', @_contentDom).html @bodyTpl.render data

	_renderFixedFooter: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .sb-mod__fixed-footer', @_contentDom).html(data).show()
			else
				$('> .sb-mod__fixed-footer', @_contentDom).html(@fixedFooterTpl.render data).show()

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
		if @ReactComponent
			react = core.getReact()
			ele = react.createElement.call react.React, @ReactComponent,
				route:
					path: @_modName
					params: @_params
			container = this._contentDom[0]
			container.innerHTML = ''
			react.render.call react.ReactDOM, ele, container
		else
			if @headerTpl
				@_renderHeader
					params: @_params
					opt: @_opt
			if @bodyTpl
				@_renderBody
					params: @_params
					opt: @_opt
			if @fixedFooterTpl
				@_renderFixedFooter
					params: @_params
					opt: @_opt
		@_onRender()

	init: ->

	$: (s) ->
		$ s, @_contentDom

	getMark: ->
		@_mark

	getModName: ->
		@_modName

	getParams: ->
		@_params

	update: (mark, params, opt) ->
		@_mark = mark
		@_params = params || @_params
		@_opt = opt || @_opt
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
			for own k, v of @parentModNames
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
		if @ReactComponent
			react = core.getReact()
			react.unmountComponentAtNode.call react.ReactDOM, @_contentDom[0] if react.unmountComponentAtNode
		@_contentDom.remove()
		@_contentDom = null

module.exports = BaseMod
