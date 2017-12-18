$ = require 'jquery'

_previousMark = undefined
_currentMark = undefined
_listener = null
_listenerBind = null
_exclamationMark = ''
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

_isValidMark = (mark) ->
  typeof mark is 'string' and not (/^[#!]/).test mark

init = (opt) ->
  opt = opt || {}
  if opt.exclamationMark
    _exclamationMark = '!'
  _isSupportHistoryState = if typeof opt.isSupportHistoryState isnt 'undefined' then opt.isSupportHistoryState else _isSupportHistoryState
  if _isSupportHistoryState
    $(window).on 'popstate', _checkMark
  else
    $(window).on 'hashchange', _checkMark
  _checkMark()
  init = ->

setListener = (listener, bind) ->
  _listener = if typeof listener is 'function' then listener else null
  _listenerBind = bind || null

push = (mark) ->
  core = require './core.coffee'
  core.view mark

setMark = (mark, opt) ->
  mark = getMark mark
  opt = opt || {}
  if opt.title
    document.title = opt.title
  if mark isnt _currentMark and _isValidMark(mark)
    _updateCurrentMark mark
    if _isSupportHistoryState
      history[if opt.replaceState then 'replaceState' else 'pushState'](opt.stateObj, opt.title || document.title, '/' + mark)
    else
      location.hash = _exclamationMark + '/' + mark

getMark = (mark) ->
  if mark
    mark.replace /^\/+/, ''
  else if _isSupportHistoryState
    location.pathname.replace /^\/+/, ''
  else
    location.hash.replace /^#!?\/*/, ''

getPrevMark = () ->
  _previousMark

isSupportHistoryState = () ->
  _isSupportHistoryState

module.exports =
  init: init
  setListener: setListener
  push: push
  setMark: setMark
  getMark: getMark
  getPrevMark: getPrevMark
  isSupportHistoryState: isSupportHistoryState
