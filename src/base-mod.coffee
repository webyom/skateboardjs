$ = require 'zepto'
core = require './core'

class BaseMod
	constructor: (modName, contentDom, args, opt) ->
		@_modName = modName
		if not contentDom
			return @
		@_contentDom = contentDom
		@_bindEvents()
		@_args = args || []
		@_opt = opt || {}
		@init()
		@_render
			args: @_args
			opt: @_opt

	showNavTab: false
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

	_ifNotCachable: (relModName, callback, elseCallback) ->
		if typeof @cachable isnt 'undefined'
			if @cachable
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

	_afterFadeOut: (relModName) ->
		@_ifNotCachable relModName, =>
			@destroy();

	_renderHeader: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .header', @_contentDom).html data
			else
				$('> .header', @_contentDom).html @_headerTpl.render data

	_renderBody: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .body', @_contentDom).html data
			else
				$('> .body', @_contentDom).html @_bodyTpl.render data

	_renderFixedFooter: (data) ->
		if @_contentDom
			if typeof data is 'string'
				$('> .fixed-footer', @_contentDom).html(data).show()
			else
				$('> .fixed-footer', @_contentDom).html(@_fixedFooterTpl.render data).show()

	_renderError: (msg) ->
		if @_contentDom
			$('> .body', @_contentDom).html [
				'<div class="body-msg" data-refresh-btn>'
					'<div class="msg">'
						msg or G.SVR_ERR_MSG
					'</div>'
					'<div class="refresh"><span class="icon icon-refresh"></span>点击刷新</div>'
				'</div>'
			].join ''
			$('> .fixed-footer', @_contentDom).hide()

	_render: ->
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

	init: ->

	$: (s) ->
		$ s, @_contentDom

	getArgs: ->
		@_args

	update: (args, opt) ->
		@_args = args || @_args
		@_opt = opt || @_opt
		@refresh()

	refresh: ->
		@scrollToTop()
		core.scroll 0
		@_render
			args: @_args
			opt: @_opt

	scrollToTop: ->
		$('> .body', @_contentDom).scrollTop 0

	isRenderred: ->
		$('[data-content-not-renderred]', @_contentDom).length is 0

	hasParent: (modName) ->
		res = @_modName.indexOf(modName + '/') is 0
		if not res
			for k, v of @parentModNames
				res = modName is k or k.indexOf(modName + '/') is 0
				break if res
		res

	fadeIn: (relModInst, animateType) ->
		core.fadeIn @_contentDom, relModInst?.hasParent(@_modName), animateType

	fadeOut: (relModName, animateType) ->
		@_contentDom.attr 'data-scene', (parseInt(@_contentDom.attr('data-scene')) or 0) + 1
		@_ifNotCachable relModName, =>
			core.removeCache @_modName
		core.fadeOut @_contentDom, @hasParent(relModName), animateType, =>
			@_afterFadeOut relModName

	captureScene: (callback) ->
		if @_contentDom
			scene = parseInt(@_contentDom.attr('data-scene')) or 0
			callback (callback) =>
				if @_contentDom
					newScene = parseInt(@_contentDom.attr('data-scene')) or 0
					callback() if newScene is scene

	destroy: () ->
		core.removeCache @_modName
		@_unbindEvents()
		@_contentDom.remove()
		@_contentDom = null

module.exports = BaseMod
