$ = require 'jquery'
history = require './history.coffee'
core = require './core.coffee'

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
    @_windowScrollTop = 0
    core.setModWindowScrollTop modName, 0
    @init()

  viewed: false
  showNavTab: false
  navTab: ''
  tabModNames: []
  events: {}
  parentModNames:
    'home': 1
  headerTpl: ''
  bodyTpl: ''
  fixedFooterTpl: ''
  moduleClassNames: ''
  ReactComponent: null

  _reactComInst: null

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
    if cachable
      elseCallback?()
    else
      callback?()

  _beforeFadeIn: ->
    @_reactComInst?.onSbBeforeFadeIn? core.getViewChangeInfo()

  _afterFadeIn: ->
    @viewed = true
    $(window).scrollTop @_windowScrollTop
    @_reactComInst?.onSbFadeIn? core.getViewChangeInfo()

  _beforeFadeOut: ->
    @_reactComInst?.onSbBeforeFadeOut? core.getViewChangeInfo()

  _afterFadeOut: (relModName) ->
    @_ifNotCachable relModName, =>
      @destroy()
    @_reactComInst?.onSbFadeOut? core.getViewChangeInfo()

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
    if typeof @moduleClassNames is 'function'
      @_contentDom.addClass @moduleClassNames()
    else if @moduleClassNames
      @_contentDom.addClass @moduleClassNames
    if @ReactComponent
      react = core.getReact()
      route = 
        mark: @_mark
        path: @_modName
        params: @_params
        opt: @_opt
      container = @_contentDom[0]
      if @isRenderred()
        if @_reactComInst?.onSbUpdate
          @_reactComInst.onSbUpdate route: route
          return
        return if not react.unmountComponentAtNode
        react.unmountComponentAtNode.call react.ReactDOM, container
      else
        container.innerHTML = ''
      ReactComponent = @ReactComponent
      ReactComponent = react.getReactComponent ReactComponent if react.getReactComponent
      ele = react.createElement.call react.React, ReactComponent,
        moduleClassNames: @moduleClassNames
        route: route
        sbModInst: @
      @_reactComInst = react.render.call react.ReactDOM, ele, container
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

  getOpt: ->
    @_opt

  getParams: ->
    @_params

  getDom: ->
    @_contentDom

  update: (mark, params, opt) ->
    @_mark = mark
    @_params = params || @_params
    @_opt = opt || @_opt
    @refresh()

  refresh: ->
    @scrollToTop()
    core.scroll 0
    @render()

  scrollToTop: (delay) ->
    dom = @$('.sb-mod__body')
    dom = @_contentDom if not dom.length
    if delay > 0
      $('html').animate scrollTop: 0, delay
      dom.animate scrollTop: 0, delay
    else
      $(window).scrollTop 0
      dom.scrollTop 0

  isRenderred: ->
    $('[data-sb-mod-not-renderred]', @_contentDom).length is 0

  hasParent: (modName) ->
    res = @_modName.indexOf(modName + '/') is 0
    if not res
      for own k, v of @parentModNames
        res = modName is k or k.indexOf(modName + '/') is 0
        break if res
    res

  hasTab: (modName) ->
    modName in @tabModNames

  getRelation: (modName) ->
    relation = ''
    if @hasTab modName
      relation = 'tab'
    else if @hasParent modName
      relation = 'parent'
    relation

  fadeIn: (relModInst, from, animateType, cb) ->
    @_beforeFadeIn()
    core.fadeIn @, @_contentDom, relModInst?.getRelation(@_modName), from, animateType, =>
      @_afterFadeIn()
      cb?()

  fadeOut: (relModName, from, animateType, cb) ->
    @_beforeFadeOut()
    if @_mark is history.getMark()
      @_windowScrollTop = $(window).scrollTop()
    else
      @_windowScrollTop = core.getModWindowScrollTop(@_modName) || 0
    @_contentDom.attr 'data-sb-scene', (parseInt(@_contentDom.attr('data-sb-scene')) or 0) + 1
    @_ifNotCachable relModName, =>
      core.removeCache @_modName
    core.fadeOut @, @_contentDom, @getRelation(relModName), from, animateType, =>
      @_afterFadeOut relModName
      cb?()

  captureScene: () ->
    captured = if not @_contentDom then -1 else parseInt(@_contentDom.attr('data-sb-scene')) or 0
    getCurrent = () =>
      if not @_contentDom then -2 else parseInt(@_contentDom.attr('data-sb-scene')) or 0
    isChanged = ->
      getCurrent() isnt captured
    doInScene = (callback) ->
      callback() if not isChanged()
    captured: captured
    getCurrent: getCurrent
    isChanged: isChanged
    doInScene: doInScene

  destroy: () ->
    core.removeCache @_modName
    @_unbindEvents()
    if @ReactComponent
      @ReactComponent = null
      @_reactComInst = null
      react = core.getReact()
      react.unmountComponentAtNode.call react.ReactDOM, @_contentDom[0] if react.unmountComponentAtNode
    @_contentDom.remove()
    @_contentDom = null

module.exports = BaseMod
