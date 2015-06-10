$ = require 'jquery'
ajaxHistory = require './ajax-history'

_modCache = {}
_currentMark = null
_currentModName = ''
_previousMark = null
_previousModName = ''
_scrollTop = 0
_viewChangeInfo = null
_opt = {}
_container = $(document.body)
_viewId = 0
_loadId = 0

_cssProps = (->
	el = document.createElement 'div'
	props =
		webkitTransition: ['webkitTransitionEnd', '-webkit-transition', '-webkit-transform']
		transition: ['transitionend', 'transition', 'transform']
	for p of props
		if el.style[p] isnt undefined
			return props[p]
	null
)()

_requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || (callback) ->
	setTimeout callback, 16

_switchNavTab = (modInst) ->
	if _opt.switchNavTab
		_opt.switchNavTab modInst
	else
		tabName = modInst.navTab
		if typeof tabName is 'function'
			tabName = tabName()
		$('nav [data-tab]', _container).removeClass 'active'
		$('nav [data-tab="' + tabName + '"]', _container).addClass 'active'

_onAfterViewChange = (modName, modInst) ->
	if _opt.onAfterViewChange
		_opt.onAfterViewChange modName, modInst
	else
		modClassName = 'body-sb-mod--' + modInst._modName.replace(/\//g, '-')
		bodyClassName = document.body.className.replace (/\bbody-sb-mod--\S+/), modClassName
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
	$(document.body).addClass 'body-sb-mod--init-mod' unless (/\bbody-sb-mod--\S+/).test document.body.className
	_container = $(_opt.container) if _opt.container
	ajaxHistory.setListener (mark) ->
		core.view mark, from: 'history'
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
			mark = el.pathname?.replace /^\/+/, ''
			if el.target
				return
			if mark is ':back'
				e.preventDefault()
				history.back()
			else if mark?.indexOf(_opt.modPrefix + '/') is 0
				e.preventDefault()
				core.view mark,
					from: 'link'
	.on 'click', '[data-refresh-btn]', () ->
		modInst = _modCache[_currentModName]
		modInst?.refresh()
	_init = ->

core = $.extend $({}),
	init: (opt) ->
		_opt = opt if opt
		_opt.defaultModName ?= 'home'
		_opt.modBase ?= ''
		_opt.modPrefix ?= 'view'
		_opt.modPrefix = _opt.modPrefix.replace /^\/+|\/+$/g, ''
		_init()

	modCacheable: ->
		_opt.modCacheable

	getPreviousModName: () ->
		_previousModName

	getCurrentModName: () ->
		_currentModName

	getCached: (modName) ->
		_modCache[modName]

	removeCache: (modName) ->
		_modCache[modName] = null

	fadeIn: (modInst, contentDom, backToParent, animateType, cb) ->
		_opt.onBeforeFadeIn? modInst
		if _opt.fadeIn
			_opt.fadeIn modInst, contentDom, backToParent, animateType, cb
		else
			res = ''
			animateType = animateType || _opt.animate?.type
			ttf = _opt.animate?.timingFunction || 'linear'
			duration = _opt.animate?.duration || 300
			callback = ->
				if animateType is 'slide'
					$('.sb-mod').css
						zIndex: '0'
					contentDom.css
						zIndex: '2'
				cb?()
			if animateType in ['fade', 'fadeIn']
				if _cssProps
					cssObj =
						opacity: '0'
					cssObj[_cssProps[1]] = 'none'
					cssObj[_cssProps[2]] = 'translateZ(0)'
					contentDom.css(cssObj).show()
					contentDom[0].offsetTop
					_requestAnimationFrame ->
						cssObj = {}
						cssObj[_cssProps[1]] = "opacity #{duration / 1000}s #{ttf}"
						cssObj['opacity'] = '1'
						contentDom.one _cssProps[0], callback
						contentDom.css cssObj
				else
					contentDom.css
						opacity: '0'
					contentDom.show()
					_requestAnimationFrame ->
						contentDom.animate
							opacity: '1'
						, duration, ttf, callback
			else if animateType is 'slide'
				sd = $('[data-slide-direction]', contentDom).data 'slide-direction'
				if _cssProps
					cssObj =
						zIndex: '2'
					cssObj[_cssProps[1]] = 'none'
					if sd in ['vu', 'vd']
						cssObj[_cssProps[2]] = 'translate3d(0, ' + (if sd is 'vd' then '-' else '') + '100%, 0)'
					else
						cssObj[_cssProps[2]] = 'translate3d(' + (if backToParent then '-' else '') + '100%, 0, 0)'
					contentDom.css(cssObj).show()
					contentDom[0].offsetTop
					_requestAnimationFrame ->
						cssObj = {}
						cssObj[_cssProps[1]] = "#{_cssProps[2]} #{duration / 1000}s #{ttf}"
						cssObj[_cssProps[2]] = 'translate3d(0, 0, 0)'
						contentDom.one _cssProps[0], callback
						contentDom.css cssObj
				else
					if sd in ['vu', 'vd']
						contentDom.css
							zIndex: '2'
							left: '0'
							top: (if sd is 'vd' then '-' else '') + '100%'
					else
						contentDom.css
							zIndex: '2'
							left: (if backToParent then '-' else '') + '100%'
							top: '0'
					contentDom.show()
					_requestAnimationFrame ->
						contentDom.animate
							left: '0'
							top: '0'
						, duration, ttf, callback
			else
				contentDom.show()
				callback()
			res

	fadeOut: (modInst, contentDom, backToParent, animateType, cb) ->
		_opt.onBeforeFadeOut? modInst
		if _opt.fadeOut
			_opt.fadeOut modInst, contentDom, backToParent, animateType, cb
		else
			res = ''
			animateType = animateType || _opt.animate?.type
			ttf = _opt.animate?.timingFunction || 'linear'
			duration = _opt.animate?.duration || 300
			callback = ->
				contentDom.hide() if contentDom.data('sb-mod') isnt _currentModName
				cb?()
			if animateType is 'fade'
				if _cssProps
					_requestAnimationFrame ->
						cssObj = {}
						cssObj[_cssProps[1]] = "opacity #{duration / 1000}s #{ttf}"
						cssObj[_cssProps[2]] = 'translateZ(0)'
						cssObj['opacity'] = '0'
						contentDom.one _cssProps[0], callback
						contentDom.css cssObj
				else
					_requestAnimationFrame ->
						contentDom.animate
							opacity: '0'
						, duration, ttf, ->
							contentDom.hide()
							callback?()
			else if animateType is 'slide'
				sd = $('[data-slide-direction]', contentDom).data 'slide-direction'
				zIndex = '1'
				percentage = '100'
				if _opt.animate?.slideOutPercent >= -100
					percentage = parseInt _opt.animate?.slideOutPercent
				if sd in ['vu', 'vd']
					res = 'fade'
					zIndex = '3'
				if _cssProps
					_requestAnimationFrame ->
						cssObj =
							zIndex: zIndex
						cssObj[_cssProps[1]] = "#{_cssProps[2]} #{duration / 1000}s #{ttf}"
						if sd in ['vu', 'vd']
							cssObj[_cssProps[2]] = 'translate3d(0, ' + (if sd is 'vd' then -100 else 100) + '%, 0)'
						else
							cssObj[_cssProps[2]] = 'translate3d(' + (if backToParent then percentage else -percentage) + '%, 0, 0)'
						contentDom.one _cssProps[0], callback
						contentDom.css cssObj
				else
					contentDom.css
						zIndex: zIndex
						left: '0'
						top: '0'
					_requestAnimationFrame ->
						if sd in ['vu', 'vd']
							contentDom.animate
								top: (if sd is 'vd' then -100 else 100) + '%'
							, duration, ttf, callback
						else
							contentDom.animate
								left: (if backToParent then percentage else -percentage) + '%'
							, duration, ttf, callback
			else
				callback()
			res

	view: (mark, opt) ->
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
		if mark.indexOf('/-/') > 0
			tmp = mark.split '/-/'
			args = tmp[1] && tmp[1].split('/') || []
		else
			tmp = mark.split '/args...'
			args = tmp[1] && tmp[1].split('.') || []
		$.each extArgs, (i, arg) ->
			if arg
				args[i] = arg
		pModName = _currentModName
		pModInst = _modCache[pModName]
		if mark.indexOf(_opt.modPrefix + '/') is 0
			modName = tmp[0].replace(_opt.modPrefix, '').replace(/^\/+|\/+$/g, '')
		modName = modName || _opt.defaultModName
		modInst = _modCache[modName]
		_viewChangeInfo =
			from: opt.from || 'api'
			scrollTop: $(window).scrollTop()
			loadFromModCache: true
			fromModName: pModName
			toModName: modName
			fromMark: _currentMark
			toMark: mark
			args: args
			opt: opt.modOpt
		return if _opt.onBeforeViewChange?(modName, modInst) is false
		if mark is _currentMark and modName isnt 'alert'
			if modInst
				modInst.refresh()
				_onAfterViewChange modName, modInst
				core.trigger 'afterViewChange', modInst
			return
		_previousMark = _currentMark
		_previousModName = _currentModName
		_currentMark = mark
		_currentModName = modName
		_viewId++
		viewId = _viewId
		if modInst \
		and modInst.isRenderred() \
		and modName isnt 'alert' \
		and modName is pModName
			modInst.update args, opt.modOpt
			_onAfterViewChange modName, modInst
			core.trigger 'afterViewChange', modInst
		else if modInst \
		and modInst.isRenderred() \
		and modName isnt 'alert' \
		and not opt.modOpt \
		and (not modInst.viewed or _viewChangeInfo.from is 'history' or _opt.alwaysUseCache or modInst.alwaysUseCache) \
		and modInst.getArgs().join('/') is args.join('/')
			modInst.fadeIn pModInst, pModInst?.fadeOut(modName), ->
				_switchNavTab modInst
				_onAfterViewChange modName, modInst
				core.trigger 'afterViewChange', modInst
		else
			_viewChangeInfo.loadFromModCache = false
			core.removeCache modName
			modInst?.destroy()
			$('[data-sb-mod="' + modName + '"]', _container).remove()
			loadMod = (modName, contentDom, args) ->
				require [_opt.modBase + 'mod/' + modName + '/main'], (ModClass) ->
					if viewId is _viewId and not _modCache[modName]
						try
							modInst = _modCache[modName] = new ModClass modName, contentDom, args, opt.modOpt
						catch e
							console?.error? e.stack
							throw e
						finally
							if modInst
								modInst._afterFadeIn pModInst
								_switchNavTab modInst
								_onAfterViewChange modName, modInst
								core.trigger 'afterViewChange', modInst
							else
								contentDom.remove()
					else
						contentDom.remove()
				, ->
					if modName isnt 'alert'
						contentDom.remove()
						core.showAlert({type: 'error', subType: 'load_mod_fail', failLoadModName: modName}, {failLoadModName: modName, holdMark: true}) if viewId is _viewId
					else
						alert 'Failed to load module "' + (opt.failLoadModName || modName) + '"'
			if _opt.initContentDom and modName is _opt.defaultModName
				contentDom = $(_opt.initContentDom)
				contentDom.attr 'data-mod-name', modName
				_opt.initContentDom = null
				loadMod modName, contentDom, args
			else
				if _opt.initContentDom
					$(_opt.initContentDom).remove()
					_opt.initContentDom = null
				contentDom = _constructContentDom(modName, args, opt.modOpt)
				core.fadeIn null, contentDom, pModInst?.hasParent(modName), pModInst?.fadeOut(modName), ->
					loadMod modName, contentDom, args
		ajaxHistory.setMark(mark, replaceState: opt.replaceState) if not opt.holdMark

	load: (mark, opt, onLoad) ->
		mark = mark.replace /^\/+/, ''
		opt = opt || {}
		extArgs = opt.args || []
		if mark.indexOf('/-/') > 0
			tmp = mark.split '/-/'
			args = tmp[1] && tmp[1].split('/') || []
		else
			tmp = mark.split '/args...'
			args = tmp[1] && tmp[1].split('.') || []
		$.each extArgs, (i, arg) ->
			if arg
				args[i] = arg
		if mark.indexOf(_opt.modPrefix + '/') is 0
			modName = tmp[0].replace(_opt.modPrefix, '').replace(/^\/+|\/+$/g, '')
		modName = modName || _opt.defaultModName
		modInst = _modCache[modName]
		_loadId++
		viewId = _viewId
		loadId = _loadId
		if modName is _currentModName \
		or modInst \
		and modInst.isRenderred() \
		and modName isnt 'alert' \
		and not opt.modOpt \
		and (_opt.alwaysUseCache or modInst.alwaysUseCache) \
		and modInst.getArgs().join('/') is args.join('/')
			onLoad()
		else
			core.removeCache modName
			modInst?.destroy()
			$('[data-sb-mod="' + modName + '"]', _container).remove()
			loadMod = (modName, contentDom, args) ->
				require [_opt.modBase + 'mod/' + modName + '/main'], (ModClass) ->
					if viewId is _viewId and loadId is _loadId and not _modCache[modName]
						try
							modInst = _modCache[modName] = new ModClass modName, contentDom, args, opt.modOpt, ->
								if viewId is _viewId and loadId is _loadId
									onLoad()
								else
									contentDom.remove()
						catch e
							contentDom.remove()
							console?.error? e.stack
							throw e
					else
						contentDom.remove()
				, ->
					if modName isnt 'alert'
						contentDom.remove()
						core.showAlert({type: 'error', subType: 'load_mod_fail', failLoadModName: modName}, {failLoadModName: modName}) if viewId is _viewId and loadId is _loadId
					else
						alert 'Failed to load module "' + (opt.failLoadModName || modName) + '"'
			contentDom = _constructContentDom(modName, args, opt.modOpt)
			loadMod modName, contentDom, args

	getViewChangeInfo: ->
		_viewChangeInfo

	scroll: (top) ->
		if _opt.scroll
			_opt.scroll top
		else
			y = top - _scrollTop
			_scrollTop = top
			if y > 0 and top > 44
				$('[data-sb-mod="' + core.getCurrentModName() + '"]').addClass 'sb-hide-header'
			else
				$('[data-sb-mod="' + core.getCurrentModName() + '"]').removeClass 'sb-hide-header'

	showAlert: (opt, viewOpt) ->
		opt = opt || {type: 'error'}
		viewOpt = viewOpt || {}
		viewOpt.modOpt = opt
		core.view 'view/alert/-/' + (new Date().getTime()), viewOpt

module.exports = core
