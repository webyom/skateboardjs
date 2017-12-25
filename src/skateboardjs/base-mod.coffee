$ = require 'jquery'
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
        window.require [core.getModBase() + relModName + '/main'], (com) =>
          relModInst = new com.Mod relModName, relModName
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
      route = 
          path: @_modName
          params: @_params
          opt: @_opt
      container = @_contentDom[0]
      if @isRenderred()
        if react.unmountComponentAtNode
          react.unmountComponentAtNode.call react.ReactDOM, container
        else
          @_reactComInst.onSbModUpdate? route: route
          return
      else
        container.innerHTML = ''
      if react.getReactComponent
        ele = react.createElement.call react.React, react.getReactComponent @ReactComponent, 
          route: route
          sbModInst: @
      else
        ele = react.createElement.call react.React, @ReactComponent,
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
    dom = @$('.sb-mod__body')
    dom = @_contentDom if not dom.length
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
    core.fadeIn @, @_contentDom, relModInst.getRelation(@_modName), from, animateType, =>
      @_afterFadeIn relModInst
      cb?()

  fadeOut: (relModName, from, animateType, cb) ->
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
