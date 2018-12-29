$ = require 'jquery'
ajaxHistory = require './history.coffee'

_modCache = {}
_modWindowScrollTop = {}
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

_isElectron = !!window.require?('electron')

_requireMod = (modName, callback, errCallback) ->
  path = _opt.modBase + modName + '/main'
  if _isElectron
    try
      callback window.require path
    catch err
      errCallback err
  else
    window.require [path], callback, errCallback

_trimSlash = (str) ->
  if str
    str.replace /^\/+|\/+$/g, ''
  else
    ''

_getParamsStr = (params) ->
  if not params
    ''
  else
    type = typeof params
    if type is 'string'
      params
    else
      tmp = []
      for own key, val of params
        tmp.push "#{key}=#{val}" if typeof val is 'string'
      tmp.join '&'

_getParamsObj = (paramsStr) ->
  params = {}
  if paramsStr
    type = typeof paramsStr
    if type is 'string'
      for tmp in paramsStr.split '&'
        tmp = tmp.split '='
        params[tmp[0]] = tmp[1]
    else
      for own key, val of paramsStr
        params[key] = val if typeof val is 'string'
  params

_isSameParams = (params1, params2) ->
  _getParamsStr(params1) is _getParamsStr(params2)

_switchNavTab = (modInst) ->
  if _opt.switchNavTab
    _opt.switchNavTab modInst
  else
    tabName = modInst.navTab
    if typeof tabName is 'function'
      tabName = tabName()
    $('app-nav [data-tab]', _container).removeClass 'active'
    $('app-nav [data-tab="' + tabName + '"]', _container).addClass 'active'

_onAfterViewChange = (info, modInst) ->
  info.toModInst = modInst
  modClassName = 'body-sb-mod--' + modInst._modName.replace(/\//g, '__')
  bodyClassName = document.body.className.replace (/\bbody-sb-mod--\S+/), modClassName
  if (/\bsb-show-nav\b/).test bodyClassName
    if not modInst.showNavTab
      bodyClassName = bodyClassName.replace (/\s*\bsb-show-nav\b/), ''
  else if modInst.showNavTab
    bodyClassName = bodyClassName + ' sb-show-nav'
  document.body.className = bodyClassName
  if _opt.onAfterViewChange
    _opt.onAfterViewChange info

_constructContentDom = (modName, params = {}, opt) ->
  if _opt.constructContentDom
    contentDom = _opt.constructContentDom modName, params, opt
  else
    try
      titleTpl = window.require _opt.modBase + modName + '/title.tpl.html'
    contentDom = $([
      '<div class="sb-mod sb-mod--' + modName.replace(/\//g, '__') + '" data-sb-mod="' + modName + '" data-sb-scene="0">'
        '<header class="sb-mod__header">'
          if titleTpl then titleTpl.render({params: params, opt: opt}) else '<h1 class="title"></h1>'
        '</header>'
        '<div class="sb-mod__body" onscroll="require(\'app\').mod.scroll(this.scrollTop);">'
          '<div class="sb-mod__body__msg" data-sb-mod-not-renderred>'
            _opt.loadingMsg || '内容正在赶来，请稍候...'
          '</div>'
        '</div>'
        '<div class="sb-mod__fixed-footer" style="display: none;">'
        '</div>'
      '</div>'
    ].join('')).prependTo _container
  contentDom

_isSameOrigin = (link) ->
  if link.origin
    if link.origin is location.origin
      return true
    else
      return false
  return (link.href + '/').indexOf(location.origin + '/') is 0

_init = ->
  $(document.body).addClass 'body-sb-mod--init-mod' unless (/\bbody-sb-mod--\S+/).test document.body.className
  _container = $(_opt.container) if _opt.container
  ajaxHistory.setListener (mark) ->
    core.view mark, from: 'history'
  ajaxHistory.init
    exclamationMark: _opt.exclamationMark
    isSupportHistoryState: _opt.isSupportHistoryState
  t = new Date()
  $(document.body).on 'click', (e) ->
    el = e.target
    mark
    t = new Date()
    if el.tagName isnt 'A'
      el = $(el).closest('a')[0]
    if el and el.tagName is 'A' and _isSameOrigin(el) and not el.target
      if (el.pathname || '/') is location.pathname and el.hash
        mark = el.hash.replace /^#!?\/*/, ''
        return if mark and el.hash.length - mark.length < 2
      else
        mark = el.pathname?.replace(/^\/+/, '') || ''
        mark += el.search if el.search
      if mark.indexOf(':back') is 0
        e.preventDefault()
        tmp = mark.split ':back:'
        if tmp.length > 1
          core.back tmp[1]
        else
          history.back()
      else if _opt.modPrefix is '' or mark.indexOf(_opt.modPrefix + '/') is 0
        e.preventDefault()
        core.view mark, from: 'link'
  .on 'click', '[data-refresh-btn]', () ->
    modInst = _modCache[_currentModName]
    modInst?.refresh()
  $(window).on 'scroll', (evt) ->
    core.setModWindowScrollTop core.getCurrentModName(), $(window).scrollTop()
  _init = ->

core = $.extend $({}),
  init: (opt) ->
    _opt = opt if opt
    _opt.defaultModName ?= 'home'
    _opt.modBase ?= ''
    _opt.modPrefix ?= ''
    _opt.modPrefix = _trimSlash _opt.modPrefix
    _init()

  modCacheable: ->
    _opt.modCacheable

  getModBase: ->
    _opt.modBase

  getReact: ->
    if not _opt.react?.React
      _opt.react = Object.assign
        React: window.React
        createElement: window.React?.createElement
        ReactDOM: window.ReactDOM
        render: window.ReactDOM?.render
        unmountComponentAtNode: window.ReactDOM?.unmountComponentAtNode
      , _opt.react
    _opt.react

  getPreviousModName: () ->
    _previousModName

  getCurrentModName: () ->
    _currentModName

  getCached: (modName) ->
    _modCache[modName]

  getModWindowScrollTop: (modName) ->
    _modWindowScrollTop[modName]

  setModWindowScrollTop: (modName, scrollTop) ->
    _modWindowScrollTop[modName] = scrollTop || 0

  removeCache: (modName) ->
    _modCache[modName] = null

  destroyCache: (modName) ->
    modInst = _modCache[modName]
    if modInst
      @removeCache modName
      modInst.destroy()
      $('[data-sb-mod="' + modName + '"]', _container).remove()
    return

  destroyAllCache: (filter) ->
    for modName of _modCache
      @destroyCache modName if filter?(modName) isnt false
    return

  fadeIn: (modInst, contentDom, relation, from, animateType, cb) ->
    fromHistory = from is 'history'
    _opt.onBeforeFadeIn? modInst
    if _opt.fadeIn
      _opt.fadeIn modInst, contentDom, relation, from, animateType, cb
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
            zIndex: '3'
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
      else if animateType is 'slide' and relation isnt 'tab'
        sd = $('[data-slide-direction]', contentDom).attr 'data-slide-direction'
        percentage = Math.min Math.max(0, _opt.animate?.slideOutPercent), 100
        if _cssProps
          cssObj = {}
          cssObj[_cssProps[1]] = 'none'
          if sd in ['vu', 'vd']
            cssObj.zIndex = '3'
            cssObj[_cssProps[2]] = 'translate3d(0, ' + (if sd is 'vd' then '-' else '') + '100%, 0)'
          else
            cssObj.zIndex = if fromHistory then '1' else '3'
            cssObj[_cssProps[2]] = 'translate3d(' + (if fromHistory then ('-' + percentage) else '100') + '%, 0, 0)'
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
              zIndex: '3'
              left: '0'
              top: (if sd is 'vd' then '-' else '') + '100%'
          else
            contentDom.css
              zIndex: if fromHistory then '1' else '3'
              left: (if fromHistory then ('-' + percentage) else '100') + '%'
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

  fadeOut: (modInst, contentDom, relation, from, animateType, cb) ->
    fromHistory = from is 'history'
    _opt.onBeforeFadeOut? modInst
    if _opt.fadeOut
      _opt.fadeOut modInst, contentDom, relation, from, animateType, cb
    else
      res = ''
      animateType = animateType || _opt.animate?.type
      ttf = _opt.animate?.timingFunction || 'linear'
      duration = _opt.animate?.duration || 300
      callback = ->
        contentDom.hide() if contentDom.attr('data-sb-mod') isnt _currentModName
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
            , duration, ttf, callback
      else if animateType is 'slide' and relation isnt 'tab'
        sd = $('[data-slide-direction]', contentDom).attr 'data-slide-direction'
        zIndex = '2'
        percentage = Math.min Math.max(0, _opt.animate?.slideOutPercent), 100
        if sd in ['vu', 'vd']
          res = 'fade'
          zIndex = '4'
        if _cssProps
          _requestAnimationFrame ->
            cssObj =
              zIndex: zIndex
            cssObj[_cssProps[1]] = "#{_cssProps[2]} #{duration / 1000}s #{ttf}"
            if sd in ['vu', 'vd']
              cssObj[_cssProps[2]] = 'translate3d(0, ' + (if sd is 'vd' then -100 else 100) + '%, 0)'
            else
              cssObj[_cssProps[2]] = 'translate3d(' + (if fromHistory then '100' else ('-' + percentage)) + '%, 0, 0)'
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
                left: (if fromHistory then '100' else ('-' + percentage)) + '%'
              , duration, ttf, callback
      else
        callback()
      res

  view: (mark, opt) ->
    mark = _trimSlash mark
    opt = opt || {}
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
    markParts = mark.split '?'
    params = $.extend _getParamsObj(markParts[1]), _getParamsObj(opt.params)
    pModName = _currentModName
    pModInst = _modCache[pModName]
    if _opt.modPrefix is '' or mark.indexOf(_opt.modPrefix + '/') is 0
      markParts = markParts[0].split '/-/'
      modName = _trimSlash markParts[0].replace(_opt.modPrefix, '')
      params = $.extend params, markParts[1].split '/' if markParts[1]
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
      fromModInst: pModInst
      toModInst: modInst
      params: params
      opt: opt.modOpt
    return if _opt.onBeforeViewChange?(_viewChangeInfo) is false
    if mark is _currentMark and modName isnt 'alert'
      if modInst
        modInst.refresh()
        _onAfterViewChange _viewChangeInfo, modInst
        core.trigger 'afterViewChange', _viewChangeInfo
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
      modInst.update mark, params, opt.modOpt
      _onAfterViewChange _viewChangeInfo, modInst
      core.trigger 'afterViewChange', _viewChangeInfo
    else if modInst \
    and modInst.isRenderred() \
    and modName isnt 'alert' \
    and not opt.modOpt \
    and (not modInst.viewed or _viewChangeInfo.from is 'history' or _opt.alwaysUseCache or modInst.alwaysUseCache or opt.useCache) \
    and _isSameParams modInst.getParams(), params
      modInst.fadeIn pModInst, opt.from, pModInst?.fadeOut(modName, opt.from), ->
        _switchNavTab modInst
        _onAfterViewChange _viewChangeInfo, modInst
        core.trigger 'afterViewChange', _viewChangeInfo
    else
      _viewChangeInfo.loadFromModCache = false
      core.destroyCache modName
      loadMod = (modName, contentDom, params) ->
        _requireMod modName, (com) ->
          if viewId is _viewId and not _modCache[modName]
            try
              modInst = _modCache[modName] = new com.Mod mark, modName, contentDom, params, opt.modOpt
              modInst.render()
              _opt.onFirstRender?()
              _opt.onFirstRender = null
            catch e
              console?.error? e.stack
              if _opt.onInitModFail
                _opt.onInitModFail mark, modName, params, opt.modOpt, 'view', viewId is _viewId
              else
                throw e
            finally
              if modInst
                modInst._afterFadeIn pModInst
                _switchNavTab modInst
                _onAfterViewChange _viewChangeInfo, modInst
                core.trigger 'afterViewChange', _viewChangeInfo
              else
                contentDom.remove()
          else
            contentDom.remove()
        , ->
          contentDom.remove()
          if _opt.onLoadModFail
            _opt.onLoadModFail mark, modName, params, opt.modOpt, 'view', viewId is _viewId
          else if modName isnt 'alert'
            core.showAlert({type: 'error', subType: 'load_mod_fail', relModName: modName}, {holdMark: true}) if viewId is _viewId
          else
            alert 'Failed to load module "' + (opt.modOpt?.relModName || '') + '"'
      if _opt.initContentDom and modName is _opt.defaultModName
        contentDom = $(_opt.initContentDom)
        contentDom.attr 'data-mod-name', modName
        _opt.initContentDom = null
        loadMod modName, contentDom, params
      else
        if _opt.initContentDom
          $(_opt.initContentDom).remove()
          _opt.initContentDom = null
        contentDom = _constructContentDom(modName, params, opt.modOpt)
        core.fadeIn null, contentDom, pModInst?.getRelation(modName), opt.from, pModInst?.fadeOut(modName, opt.from), ->
          loadMod modName, contentDom, params
    ajaxHistory.setMark(mark, replaceState: opt.replaceState) if not opt.holdMark

  load: (mark, opt, onLoad) ->
    mark = _trimSlash mark
    opt = opt || {}
    markParts = mark.split '?'
    params = $.extend _getParamsObj(markParts[1]), _getParamsObj(opt.params)
    if _opt.modPrefix is '' or mark.indexOf(_opt.modPrefix + '/') is 0
      markParts = markParts[0].split '/-/'
      modName = _trimSlash markParts[0].replace(_opt.modPrefix, '')
      params = $.extend params, markParts[1].split '/' if markParts[1]
    modName = modName || _opt.defaultModName
    modInst = _modCache[modName]
    _loadId++ if onLoad
    viewId = _viewId
    loadId = _loadId
    if modName is _currentModName \
    or modInst \
    and modInst.isRenderred() \
    and modName isnt 'alert' \
    and not opt.modOpt \
    and (_opt.alwaysUseCache or modInst.alwaysUseCache) \
    and _isSameParams modInst.getParams(), params
      onLoad?()
    else
      core.destroyCache modName
      loadMod = (modName, contentDom, params) ->
        _requireMod modName, (com) ->
          if viewId is _viewId and loadId is _loadId and not _modCache[modName]
            try
              modInst = _modCache[modName] = new com.Mod mark, modName, contentDom, params, opt.modOpt, ->
                if viewId is _viewId and loadId is _loadId
                  onLoad?()
              modInst.render()
            catch e
              contentDom.remove()
              console?.error? e.stack
              if _opt.onInitModFail
                _opt.onInitModFail mark, modName, params, opt.modOpt, 'load', viewId is _viewId and loadId is _loadId
              else
                throw e
          else
            contentDom.remove()
        , ->
          if onLoad
            if _opt.onLoadModFail
              contentDom.remove()
              _opt.onLoadModFail mark, modName, params, opt.modOpt, 'load', viewId is _viewId and loadId is _loadId
            else if modName isnt 'alert'
              contentDom.remove()
              core.showAlert({type: 'error', subType: 'load_mod_fail', relModName: modName}, {}) if viewId is _viewId and loadId is _loadId
            else
              alert 'Failed to load module "' + (opt.modOpt?.relModName || '') + '"'
      contentDom = _constructContentDom(modName, params, opt.modOpt)
      loadMod modName, contentDom, params

  back: (mark) ->
    mark = _trimSlash mark
    markParts = mark.split '?'
    params = markParts[1]
    if _opt.modPrefix is '' or mark.indexOf(_opt.modPrefix + '/') is 0
      markParts = markParts[0].split '/-/'
      modName = _trimSlash markParts[0].replace(_opt.modPrefix, '')
      params = params || markParts[1]
    if modName
      modInst = _modCache[modName]
      if modInst
        if params
          if mark is modInst.getMark()
            core.view mark, from: 'history'
          else
            core.view mark, from: 'link'
        else
          core.view modInst.getMark(), from: 'history'
      else
        core.view mark, from: 'link'
    else
      history.back()

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
    core.view _opt.modPrefix + '/' + (_opt.alertModName || 'alert') + '?t=' + (new Date().getTime()), viewOpt

  captureScene: () ->
    modInst = _modCache[_currentMark]
    if modInst
      modInst.captureScene()
    else
      captured: -1
      getCurrent: () -> -2
      isChanged: () -> true
      doInScene: () ->

module.exports = core
