$ = require 'jquery'

_markCacheIndexHash = {}
_cache = []
_cacheEnabled = true
_cacheSize = 100
_previousMark = undefined
_currentMark = undefined
_listener = null
_listenerBind = null
_isSupportHistoryState = !!history.pushState

_updateCurrentMark = (mark) ->
	if mark isnt _currentMark
		_previousMark = _currentMark
		_currentMark = mark

_checkMark = () ->
	mark = getMark()
	if mark isnt _currentMark and _isValidMark mark
		_updateCurrentMark mark
		_listener.call(_listenerBind, mark) if _listener

_setCache = (mark, data) ->
	if _cacheEnabled
		delete _cache[_markCacheIndexHash[mark]]
		_cache.push data
		_markCacheIndexHash[mark] = _cache.length - 1
		delete _cache[_markCacheIndexHash[mark] - _cacheSize]

_isValidMark = (mark) ->
	typeof mark is 'string' and not (/^[#!]/).test mark

init = (opt) ->
	opt = opt || {}
	_isSupportHistoryState = if typeof opt.isSupportHistoryState isnt 'undefined' then opt.isSupportHistoryState else _isSupportHistoryState
	_cacheEnabled = if typeof opt.cacheEnabled isnt 'undefined' then opt.cacheEnabled else _cacheEnabled
	_cacheSize = opt.cacheSize || _cacheSize
	if _isSupportHistoryState
		$(window).on 'popstate', _checkMark
	else
		$(window).on 'hashchange', _checkMark
	_checkMark()
	init = ->
	
setListener = (listener, bind) ->
	_listener = if typeof listener is 'function' then listener else null
	_listenerBind = bind || null

setCache = (mark, data) ->
	if _isValidMark mark
		_setCache mark, data

getCache = (mark) ->
	_cache[_markCacheIndexHash[mark]]

clearCache = () ->
	_markCacheIndexHash = {}
	_cache = []

setMark = (mark, opt) ->
	opt = opt || {}
	if opt.title
		document.title = opt.title
	if mark isnt _currentMark and _isValidMark(mark)
		_updateCurrentMark mark
		if _isSupportHistoryState
			history[if opt.replaceState then 'replaceState' else 'pushState'](opt.stateObj, opt.title || document.title, '/' + mark)
		else
			location.hash = '!' + mark

getMark = () ->
	if _isSupportHistoryState
		location.pathname.replace /^\//, ''
	else
		location.hash.replace /^#!?\/?/, ''

getPrevMark = () ->
	_previousMark

isSupportHistoryState = () ->
	_isSupportHistoryState
	
module.exports =
	init: init
	setListener: setListener
	setCache: setCache
	getCache: getCache
	clearCache: clearCache
	setMark: setMark
	getMark: getMark
	getPrevMark: getPrevMark
	isSupportHistoryState: isSupportHistoryState
