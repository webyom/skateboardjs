$ = require 'jquery'
ajaxHistory = require './ajax-history'

_modCache = {}
_currentMark = null
_currentModName = ''
_previousMark = null
_previousModName = ''
_scrollTop = 0
_opt = {}
_container = $(document.body)

_switchNavTab = (modInst) ->
	if _opt.switchNavTab
		_opt.switchNavTab modInst
	else
		tabName = modInst.navTab
		if typeof tabName is 'function'
			tabName = tabName()
		$('nav [data-tab]', _container).removeClass 'active'
		$('nav [data-tab="' + tabName + '"]', _container).addClass 'active'
		modClassName = 'sb-mod--' + modInst._modName.replace(/\//g, '-')
		bodyClassName = document.body.className.replace (/\bsb-mod--\S+/), modClassName
		if (/\bsb-show-nav\b/).test bodyClassName
			if not modInst.showNavTab
				bodyClassName = bodyClassName.replace (/\s*\bsb-show-nav\b/), ''
		else if modInst.showNavTab
			bodyClassName = bodyClassName + ' sb-show-nav'
		document.body.className = bodyClassName

_constructContentDom = (modName, args, opt) ->
	if _opt.constructContentDom
		contentDom = _opt.constructContentDom modName, args, opt
	else
		titleTpl = require _opt.modBase + 'mod/' + modName + '/title.tpl.html'
		contentDom = $([
			'<div class="sb-mod sb-mod--' + modName.replace(/\//g, '-') + '" data-sb-mod="' + modName + '" data-sb-scene="0">'
				'<header class="sb-mod__header">'
					if titleTpl then titleTpl.render({args: args, opt: opt}) else '<h1 class="title"></h1>'
				'</header>'
				'<div class="sb-mod__body" onscroll="require(\'app\').mod.scroll(this.scrollTop);">'
					'<div class="sb-mod__body__msg" data-sb-mod-not-renderred>'
						'内容正在赶来，请稍候...'
					'</div>'
				'</div>'
				'<div class="sb-mod__fixed-footer" style="display: none;">'
				'</div>'
			'</div>'
		].join('')).prependTo _container
	contentDom

_init = ->
	$(document.body).addClass 'sb-mod--init-mod' unless (/\bsb-mod--\S+/).test document.body.className
	_container = $(_opt.container) if _opt.container
	ajaxHistory.setListener (mark) ->
		view mark, fromHistory: true
	ajaxHistory.init
		isSupportHistoryState: _opt.isSupportHistoryState
	t = new Date()
	$(document.body).on 'click', (e) ->
		el = e.target
		mark
		t = new Date()
		if el.tagName isnt 'A'
			el = $(el).closest('a')[0]
		if el and el.tagName is 'A'
			mark = el.pathname
			if el.target
				return
			if mark is '/:back'
				e.preventDefault()
				history.back()
			else if mark.indexOf('/' + _opt.modPrefix + '/') is 0
				e.preventDefault()
				view mark
	.on 'click', '[data-refresh-btn]', () ->
		modInst = _modCache[_currentModName]
		modInst?.refresh()
	_init = ->

init = (opt) ->
	_opt = opt if opt
	_opt.defaultModName ?= 'home'
	_opt.modPrefix ?= 'view'
	_opt.modBase ?= ''
	_init()

getPreviousModName = () ->
	_previousModName

getCurrentModName = () ->
	_currentModName

getCached = (modName) ->
	_modCache[modName]

removeCache = (modName) ->
	_modCache[modName] = null

fadeIn = (modInst, contentDom, backToParent, animateType, cb) ->
	_opt.onBeforeFadeIn? modInst
	res = ''
	animateType = animateType || _opt.animate?.type
	ttf = _opt.animate?.timingFunction || 'linear'
	duration = _opt.animate?.duration || 300
	callback = ->
		if animateType is 'fade' or animateType is 'fadeIn'
			contentDom.show()
		else if animateType is 'slide'
			$('.sb-mod').css
				zIndex: '0'
			contentDom.css
				zIndex: '1'
		cb?()
	contentDom.show()
	if animateType is 'fade' or animateType is 'fadeIn'
		contentDom.css
			opacity: '0'
		contentDom.show()
		setTimeout ->
			contentDom.animate
				opacity: '1'
			, duration, ttf, callback
		, 0
	else if animateType is 'slide'
		sd = $('[data-slide-direction]', contentDom).data 'slide-direction'
		if _opt.transformAnimation is false
			if sd in ['vu', 'vd']
				contentDom.css
					zIndex: '1'
					top: (if sd is 'vd' then '-' else '') + '100%'
			else
				contentDom.css
					zIndex: '1'
					left: (if backToParent then '-' else '') + '100%'
			setTimeout ->
				contentDom.animate
					'-webkit-transform': 'translate3d(0, 0, 0)'
					left: '0'
					top: '0'
				, duration, ttf, callback
			, 0
		else
			if sd in ['vu', 'vd']
				contentDom.css
					zIndex: '1'
					'-webkit-transform': 'translate3d(0, ' + (if sd is 'vd' then '-' else '') + '100%, 0)'
					transform: 'translate3d(0, ' + (if sd is 'vd' then '-' else '') + '100%, 0)'
			else
				contentDom.css
					zIndex: '1'
					'-webkit-transform': 'translate3d(' + (if backToParent then '-' else '') + '100%, 0, 0)'
					transform: 'translate3d(' + (if backToParent then '-' else '') + '100%, 0, 0)'
			setTimeout ->
				contentDom.animate
					'-webkit-transform': 'translate3d(0, 0, 0)'
					transform: 'translate3d(0, 0, 0)'
				, duration, ttf, callback
			, 0
	else
		callback()
	res

fadeOut = (modInst, contentDom, backToParent, animateType, cb) ->
	_opt.onBeforeFadeOut? modInst
	res = ''
	animateType = animateType || _opt.animate?.type
	ttf = _opt.animate?.timingFunction || 'linear'
	duration = _opt.animate?.duration || 300
	callback = ->
		contentDom.hide() if contentDom.data('sb-mod') isnt _currentModName
		cb?()
	if animateType is 'fade'
		contentDom.css
			opacity: '1'
		setTimeout ->
			contentDom.animate
				opacity: '0'
			, duration, ttf, ->
				contentDom.hide()
				callback?()
		, 0
	else if animateType is 'slide'
		sd = $('[data-slide-direction]', contentDom).data 'slide-direction'
		if sd in ['vu', 'vd']
			res = 'fade'
		$('.sb-mod').css
			zIndex: '0'
		if _opt.transformAnimation is false
			contentDom.css
				zIndex: '2'
				left: '0'
				top: '0'
			setTimeout ->
				if sd in ['vu', 'vd']
					contentDom.animate
						top: (if sd is 'vd' then '-' else '') + '100%'
					, duration, ttf, callback
				else
					contentDom.animate
						left: (if backToParent then '' else '-') + '100%'
					, duration, ttf, callback
			, 0
		else
			contentDom.css
				zIndex: '2'
				'-webkit-transform': 'translate3d(0, 0, 0)'
				transform: 'translate3d(0, 0, 0)'
			setTimeout ->
				if sd in ['vu', 'vd']
					contentDom.animate
						'-webkit-transform': 'translate3d(0, ' + (if sd is 'vd' then '-' else '') + '100%, 0)'
						transform: 'translate3d(0, ' + (if sd is 'vd' then '-' else '') + '100%, 0)'
					, duration, ttf, callback
				else
					contentDom.animate
						'-webkit-transform': 'translate3d(' + (if backToParent then '' else '-') + '100%, 0, 0)'
						transform: 'translate3d(' + (if backToParent then '' else '-') + '100%, 0, 0)'
					, duration, ttf, callback
			, 0
	else
		callback()
	res

view = (mark, opt) ->
	mark = mark.replace /^\/+/, ''
	opt = opt || {}
	extArgs = opt.args || []
	if opt.reload
		if ajaxHistory.isSupportHistoryState()
			if location.origin + '/' + mark is location.href
				location.reload()
			else
				location.href = '/' + mark
		else
			ajaxHistory.setMark mark
			location.reload()
		return
	if (/\/-\//).test mark
		tmp = mark.split '/-/'
		args = tmp[1] && tmp[1].split('/') || []
	else
		tmp = mark.split '/args...'
		args = tmp[1] && tmp[1].split('.') || []
	pModName = _currentModName
	pModInst = _modCache[pModName]
	modName = tmp[0].replace new RegExp('\\/?' + _opt.modPrefix + '\\/?'), ''
	modName = modName || _opt.defaultModName
	modInst = _modCache[modName]
	_opt.onBeforeChangeView?()
	if mark is _currentMark and modName isnt 'alert'
		modInst?.refresh()
		_switchNavTab modInst
		_opt.onAfterViewChange? modInst,
			fromHistory: opt.fromHistory
			cacheView: true
			refresh: true
		return
	_previousMark = _currentMark
	_previousModName = _currentModName
	_currentMark = mark
	_currentModName = modName
	$.each extArgs, (i, arg) ->
		if arg
			args[i] = arg
	if modInst and modInst.isRenderred() and modName isnt 'alert' and modName is pModName
		modInst.update args, opt.modOpt
	else if modInst and modInst.isRenderred() and modName isnt 'alert' and not opt.modOpt and modInst.getArgs().join('/') is args.join('/')
		modInst.fadeIn pModInst, pModInst?.fadeOut(modName)
		_switchNavTab modInst
		_opt.onAfterViewChange? modInst,
			fromHistory: opt.fromHistory
			cacheView: true
	else
		removeCache modName
		$('[data-sb-mod="' + modName + '"]', _container).remove()
		((modName, contentDom, args, pModName) ->
			fadeIn null, contentDom, pModInst?.hasParent(modName), pModInst?.fadeOut(modName)
			require [_opt.modBase + 'mod/' + modName + '/main'], (ModClass) ->
				if modName is _currentModName and not _modCache[modName]
					modInst = _modCache[modName] = new ModClass modName, contentDom, args, opt.modOpt
					_switchNavTab modInst
					_opt.onAfterViewChange? modInst,
						fromHistory: opt.fromHistory
				else
					contentDom.remove()
			, ->
				if modName isnt 'alert'
					contentDom.remove()
					showAlert({type: 'error', subType: 'load_mod_fail', modName: modName}, {holdMark: true}) if modName is _currentModName
		)(modName, _constructContentDom(modName, args, opt.modOpt), args, pModName)
	ajaxHistory.setMark(mark, replaceState: opt.replaceState) if not opt.holdMark

scroll = (top) ->
	if _opt.scroll
		_opt.scroll top
	else
		y = top - _scrollTop
		_scrollTop = top
		if y > 0 and top > 44
			$('[data-sb-mod="' + getCurrentModName() + '"]').addClass 'sb-hide-header'
		else
			$('[data-sb-mod="' + getCurrentModName() + '"]').removeClass 'sb-hide-header'

showAlert = (opt, viewOpt) ->
	opt = opt || {type: 'error'}
	viewOpt = viewOpt || {}
	viewOpt.modOpt = opt
	view 'view/alert/-/' + (new Date().getTime()), viewOpt

module.exports =
	init: init
	getPreviousModName: getPreviousModName
	getCurrentModName: getCurrentModName
	getCached: getCached
	removeCache: removeCache
	fadeIn: fadeIn
	fadeOut: fadeOut
	view: view
	scroll: scroll
	showAlert: showAlert
