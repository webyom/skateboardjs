define(['require', 'exports', 'module', './core', './base-mod'], function(require, exports, module) {
(function() {
  var BaseMod, core;

  core = require('./core');

  BaseMod = require('./base-mod');

  module.exports = {
    core: core,
    BaseMod: BaseMod
  };

}).call(this);

});

define('./core', ['require', 'exports', 'module', 'jquery', './ajax-history'], function(require, exports, module) {
(function() {
  var $, _constructContentDom, _container, _currentMark, _currentModName, _init, _modCache, _onAfterViewChange, _opt, _previousMark, _previousModName, _scrollTop, _switchNavTab, _viewChangeInfo, ajaxHistory, core;

  $ = require('jquery');

  ajaxHistory = require('./ajax-history');

  _modCache = {};

  _currentMark = null;

  _currentModName = '';

  _previousMark = null;

  _previousModName = '';

  _scrollTop = 0;

  _viewChangeInfo = null;

  _opt = {};

  _container = $(document.body);

  _switchNavTab = function(modInst) {
    var tabName;
    if (_opt.switchNavTab) {
      return _opt.switchNavTab(modInst);
    } else {
      tabName = modInst.navTab;
      if (typeof tabName === 'function') {
        tabName = tabName();
      }
      $('nav [data-tab]', _container).removeClass('active');
      return $('nav [data-tab="' + tabName + '"]', _container).addClass('active');
    }
  };

  _onAfterViewChange = function(modInst) {
    var bodyClassName, modClassName;
    if (_opt.onAfterViewChange) {
      return _opt.onAfterViewChange(modInst);
    } else {
      modClassName = 'body-sb-mod--' + modInst._modName.replace(/\//g, '-');
      bodyClassName = document.body.className.replace(/\bbody-sb-mod--\S+/, modClassName);
      if (/\bsb-show-nav\b/.test(bodyClassName)) {
        if (!modInst.showNavTab) {
          bodyClassName = bodyClassName.replace(/\s*\bsb-show-nav\b/, '');
        }
      } else if (modInst.showNavTab) {
        bodyClassName = bodyClassName + ' sb-show-nav';
      }
      return document.body.className = bodyClassName;
    }
  };

  _constructContentDom = function(modName, args, opt) {
    var contentDom, titleTpl;
    if (_opt.constructContentDom) {
      contentDom = _opt.constructContentDom(modName, args, opt);
    } else {
      titleTpl = require(_opt.modBase + 'mod/' + modName + '/title.tpl.html');
      contentDom = $([
        '<div class="sb-mod sb-mod--' + modName.replace(/\//g, '-') + '" data-sb-mod="' + modName + '" data-sb-scene="0">', '<header class="sb-mod__header">', titleTpl ? titleTpl.render({
          args: args,
          opt: opt
        }) : '<h1 class="title"></h1>', '</header>', '<div class="sb-mod__body" onscroll="require(\'app\').mod.scroll(this.scrollTop);">', '<div class="sb-mod__body__msg" data-sb-mod-not-renderred>', '内容正在赶来，请稍候...', '</div>', '</div>', '<div class="sb-mod__fixed-footer" style="display: none;">', '</div>', '</div>'
      ].join('')).prependTo(_container);
    }
    return contentDom;
  };

  _init = function() {
    var t;
    if (!/\bbody-sb-mod--\S+/.test(document.body.className)) {
      $(document.body).addClass('body-sb-mod--init-mod');
    }
    if (_opt.container) {
      _container = $(_opt.container);
    }
    ajaxHistory.setListener(function(mark) {
      return core.view(mark, {
        from: 'history'
      });
    });
    ajaxHistory.init({
      isSupportHistoryState: _opt.isSupportHistoryState
    });
    t = new Date();
    $(document.body).on('click', function(e) {
      var el, mark, ref;
      el = e.target;
      mark;
      t = new Date();
      if (el.tagName !== 'A') {
        el = $(el).closest('a')[0];
      }
      if (el && el.tagName === 'A') {
        mark = (ref = el.pathname) != null ? ref.replace(/^\/+/, '') : void 0;
        if (el.target) {
          return;
        }
        if (mark === '/:back') {
          e.preventDefault();
          return history.back();
        } else if ((mark != null ? mark.indexOf(_opt.modPrefix + '/') : void 0) === 0) {
          e.preventDefault();
          return core.view(mark, {
            from: 'link'
          });
        }
      }
    }).on('click', '[data-refresh-btn]', function() {
      var modInst;
      modInst = _modCache[_currentModName];
      return modInst != null ? modInst.refresh() : void 0;
    });
    return _init = function() {};
  };

  core = $.extend($({}), {
    init: function(opt) {
      if (opt) {
        _opt = opt;
      }
      if (_opt.defaultModName == null) {
        _opt.defaultModName = 'home';
      }
      if (_opt.modBase == null) {
        _opt.modBase = '';
      }
      if (_opt.modPrefix == null) {
        _opt.modPrefix = 'view';
      }
      _opt.modPrefix = _opt.modPrefix.replace(/^\/+|\/+$/g, '');
      return _init();
    },
    getPreviousModName: function() {
      return _previousModName;
    },
    getCurrentModName: function() {
      return _currentModName;
    },
    getCached: function(modName) {
      return _modCache[modName];
    },
    removeCache: function(modName) {
      return _modCache[modName] = null;
    },
    fadeIn: function(modInst, contentDom, backToParent, animateType, cb) {
      var callback, duration, ref, ref1, ref2, res, sd, ttf;
      if (typeof _opt.onBeforeFadeIn === "function") {
        _opt.onBeforeFadeIn(modInst);
      }
      res = '';
      animateType = animateType || ((ref = _opt.animate) != null ? ref.type : void 0);
      ttf = ((ref1 = _opt.animate) != null ? ref1.timingFunction : void 0) || 'linear';
      duration = ((ref2 = _opt.animate) != null ? ref2.duration : void 0) || 300;
      callback = function() {
        if (animateType === 'slide') {
          $('.sb-mod').css({
            zIndex: '0'
          });
          contentDom.css({
            zIndex: '1'
          });
        }
        return typeof cb === "function" ? cb() : void 0;
      };
      contentDom.show();
      if (animateType === 'fade' || animateType === 'fadeIn') {
        contentDom.css({
          opacity: '0'
        });
        contentDom.show();
        setTimeout(function() {
          return contentDom.animate({
            opacity: '1'
          }, duration, ttf, callback);
        }, 0);
      } else if (animateType === 'slide') {
        sd = $('[data-slide-direction]', contentDom).data('slide-direction');
        if (_opt.transformAnimation === false) {
          if (sd === 'vu' || sd === 'vd') {
            contentDom.css({
              zIndex: '1',
              top: (sd === 'vd' ? '-' : '') + '100%'
            });
          } else {
            contentDom.css({
              zIndex: '1',
              left: (backToParent ? '-' : '') + '100%'
            });
          }
          setTimeout(function() {
            return contentDom.animate({
              '-webkit-transform': 'translate3d(0, 0, 0)',
              left: '0',
              top: '0'
            }, duration, ttf, callback);
          }, 0);
        } else {
          if (sd === 'vu' || sd === 'vd') {
            contentDom.css({
              zIndex: '1',
              '-webkit-transform': 'translate3d(0, ' + (sd === 'vd' ? '-' : '') + '100%, 0)',
              transform: 'translate3d(0, ' + (sd === 'vd' ? '-' : '') + '100%, 0)'
            });
          } else {
            contentDom.css({
              zIndex: '1',
              '-webkit-transform': 'translate3d(' + (backToParent ? '-' : '') + '100%, 0, 0)',
              transform: 'translate3d(' + (backToParent ? '-' : '') + '100%, 0, 0)'
            });
          }
          setTimeout(function() {
            return contentDom.animate({
              '-webkit-transform': 'translate3d(0, 0, 0)',
              transform: 'translate3d(0, 0, 0)'
            }, duration, ttf, callback);
          }, 0);
        }
      } else {
        callback();
      }
      return res;
    },
    fadeOut: function(modInst, contentDom, backToParent, animateType, cb) {
      var callback, duration, ref, ref1, ref2, res, sd, ttf;
      if (typeof _opt.onBeforeFadeOut === "function") {
        _opt.onBeforeFadeOut(modInst);
      }
      res = '';
      animateType = animateType || ((ref = _opt.animate) != null ? ref.type : void 0);
      ttf = ((ref1 = _opt.animate) != null ? ref1.timingFunction : void 0) || 'linear';
      duration = ((ref2 = _opt.animate) != null ? ref2.duration : void 0) || 300;
      callback = function() {
        if (contentDom.data('sb-mod') !== _currentModName) {
          contentDom.hide();
        }
        return typeof cb === "function" ? cb() : void 0;
      };
      if (animateType === 'fade') {
        contentDom.css({
          opacity: '1'
        });
        setTimeout(function() {
          return contentDom.animate({
            opacity: '0'
          }, duration, ttf, function() {
            contentDom.hide();
            return typeof callback === "function" ? callback() : void 0;
          });
        }, 0);
      } else if (animateType === 'slide') {
        sd = $('[data-slide-direction]', contentDom).data('slide-direction');
        if (sd === 'vu' || sd === 'vd') {
          res = 'fade';
        }
        $('.sb-mod').css({
          zIndex: '0'
        });
        if (_opt.transformAnimation === false) {
          contentDom.css({
            zIndex: '2',
            left: '0',
            top: '0'
          });
          setTimeout(function() {
            if (sd === 'vu' || sd === 'vd') {
              return contentDom.animate({
                top: (sd === 'vd' ? '-' : '') + '100%'
              }, duration, ttf, callback);
            } else {
              return contentDom.animate({
                left: (backToParent ? '' : '-') + '100%'
              }, duration, ttf, callback);
            }
          }, 0);
        } else {
          contentDom.css({
            zIndex: '2',
            '-webkit-transform': 'translate3d(0, 0, 0)',
            transform: 'translate3d(0, 0, 0)'
          });
          setTimeout(function() {
            if (sd === 'vu' || sd === 'vd') {
              return contentDom.animate({
                '-webkit-transform': 'translate3d(0, ' + (sd === 'vd' ? '-' : '') + '100%, 0)',
                transform: 'translate3d(0, ' + (sd === 'vd' ? '-' : '') + '100%, 0)'
              }, duration, ttf, callback);
            } else {
              return contentDom.animate({
                '-webkit-transform': 'translate3d(' + (backToParent ? '' : '-') + '100%, 0, 0)',
                transform: 'translate3d(' + (backToParent ? '' : '-') + '100%, 0, 0)'
              }, duration, ttf, callback);
            }
          }, 0);
        }
      } else {
        callback();
      }
      return res;
    },
    view: function(mark, opt) {
      var args, extArgs, modInst, modName, pModInst, pModName, tmp;
      mark = mark.replace(/^\/+/, '');
      opt = opt || {};
      extArgs = opt.args || [];
      if (opt.reload) {
        if (ajaxHistory.isSupportHistoryState()) {
          if (location.origin + '/' + mark === location.href) {
            location.reload();
          } else {
            location.href = '/' + mark;
          }
        } else {
          ajaxHistory.setMark(mark);
          location.reload();
        }
        return;
      }
      if (mark.indexOf('/-/') > 0) {
        tmp = mark.split('/-/');
        args = tmp[1] && tmp[1].split('/') || [];
      } else {
        tmp = mark.split('/args...');
        args = tmp[1] && tmp[1].split('.') || [];
      }
      pModName = _currentModName;
      pModInst = _modCache[pModName];
      if (mark.indexOf(_opt.modPrefix + '/') === 0) {
        modName = tmp[0].replace(_opt.modPrefix, '').replace(/^\/+|\/+$/g, '');
      }
      modName = modName || _opt.defaultModName;
      modInst = _modCache[modName];
      _viewChangeInfo = {
        from: opt.from || 'api',
        loadFromModCache: true,
        fromModName: pModName,
        toModName: modName,
        fromMark: _currentMark,
        toMark: mark
      };
      if (typeof _opt.onBeforeViewChange === "function") {
        _opt.onBeforeViewChange();
      }
      if (mark === _currentMark && modName !== 'alert') {
        if (modInst) {
          modInst.refresh();
          _onAfterViewChange(modInst);
          core.trigger('afterViewChange', modInst);
        }
        return;
      }
      _previousMark = _currentMark;
      _previousModName = _currentModName;
      _currentMark = mark;
      _currentModName = modName;
      $.each(extArgs, function(i, arg) {
        if (arg) {
          return args[i] = arg;
        }
      });
      if (modInst && modInst.isRenderred() && modName !== 'alert' && modName === pModName) {
        modInst.update(args, opt.modOpt);
        _onAfterViewChange(modInst);
        core.trigger('afterViewChange', modInst);
      } else if (modInst && modInst.isRenderred() && modName !== 'alert' && !opt.modOpt && modInst.getArgs().join('/') === args.join('/')) {
        modInst.fadeIn(pModInst, pModInst != null ? pModInst.fadeOut(modName) : void 0);
        _switchNavTab(modInst);
        _onAfterViewChange(modInst);
        core.trigger('afterViewChange', modInst);
      } else {
        _viewChangeInfo.loadFromModCache = false;
        core.removeCache(modName);
        $('[data-sb-mod="' + modName + '"]', _container).remove();
        (function(modName, contentDom, args, pModName) {
          core.fadeIn(null, contentDom, pModInst != null ? pModInst.hasParent(modName) : void 0, pModInst != null ? pModInst.fadeOut(modName) : void 0);
          return require([_opt.modBase + 'mod/' + modName + '/main'], function(ModClass) {
            var e;
            if (modName === _currentModName && !_modCache[modName]) {
              try {
                return modInst = _modCache[modName] = new ModClass(modName, contentDom, args, opt.modOpt);
              } catch (_error) {
                e = _error;
                if (typeof console !== "undefined" && console !== null) {
                  if (typeof console.error === "function") {
                    console.error(e.stack);
                  }
                }
                throw e;
              } finally {
                if (modInst) {
                  modInst._afterFadeIn(pModInst);
                  _switchNavTab(modInst);
                  _onAfterViewChange(modInst);
                  core.trigger('afterViewChange', modInst);
                } else {
                  contentDom.remove();
                }
              }
            } else {
              return contentDom.remove();
            }
          }, function() {
            if (modName !== 'alert') {
              contentDom.remove();
              if (modName === _currentModName) {
                return core.showAlert({
                  type: 'error',
                  subType: 'load_mod_fail',
                  failLoadModName: modName
                }, {
                  failLoadModName: modName,
                  holdMark: true
                });
              }
            } else {
              return alert('Failed to load module "' + (opt.failLoadModName || modName) + '"');
            }
          });
        })(modName, _constructContentDom(modName, args, opt.modOpt), args, pModName);
      }
      if (!opt.holdMark) {
        return ajaxHistory.setMark(mark, {
          replaceState: opt.replaceState
        });
      }
    },
    getViewChangeInfo: function() {
      return _viewChangeInfo;
    },
    scroll: function(top) {
      var y;
      if (_opt.scroll) {
        return _opt.scroll(top);
      } else {
        y = top - _scrollTop;
        _scrollTop = top;
        if (y > 0 && top > 44) {
          return $('[data-sb-mod="' + core.getCurrentModName() + '"]').addClass('sb-hide-header');
        } else {
          return $('[data-sb-mod="' + core.getCurrentModName() + '"]').removeClass('sb-hide-header');
        }
      }
    },
    showAlert: function(opt, viewOpt) {
      opt = opt || {
        type: 'error'
      };
      viewOpt = viewOpt || {};
      viewOpt.modOpt = opt;
      return core.view('view/alert/-/' + (new Date().getTime()), viewOpt);
    }
  });

  module.exports = core;

}).call(this);

});

define('./ajax-history', ['require', 'exports', 'module', 'jquery'], function(require, exports, module) {
(function() {
  var $, _cache, _cacheEnabled, _cacheSize, _checkMark, _currentMark, _isSupportHistoryState, _isValidMark, _listener, _listenerBind, _markCacheIndexHash, _previousMark, _setCache, _updateCurrentMark, clearCache, getCache, getMark, getPrevMark, init, isSupportHistoryState, setCache, setListener, setMark;

  $ = require('jquery');

  _markCacheIndexHash = {};

  _cache = [];

  _cacheEnabled = true;

  _cacheSize = 100;

  _previousMark = void 0;

  _currentMark = void 0;

  _listener = null;

  _listenerBind = null;

  _isSupportHistoryState = !!history.pushState;

  _updateCurrentMark = function(mark) {
    if (mark !== _currentMark) {
      _previousMark = _currentMark;
      return _currentMark = mark;
    }
  };

  _checkMark = function() {
    var mark;
    mark = getMark();
    if (mark !== _currentMark && _isValidMark(mark)) {
      _updateCurrentMark(mark);
      if (_listener) {
        return _listener.call(_listenerBind, mark);
      }
    }
  };

  _setCache = function(mark, data) {
    if (_cacheEnabled) {
      delete _cache[_markCacheIndexHash[mark]];
      _cache.push(data);
      _markCacheIndexHash[mark] = _cache.length - 1;
      return delete _cache[_markCacheIndexHash[mark] - _cacheSize];
    }
  };

  _isValidMark = function(mark) {
    return typeof mark === 'string' && !/^[#!]/.test(mark);
  };

  init = function(opt) {
    opt = opt || {};
    _isSupportHistoryState = typeof opt.isSupportHistoryState !== 'undefined' ? opt.isSupportHistoryState : _isSupportHistoryState;
    _cacheEnabled = typeof opt.cacheEnabled !== 'undefined' ? opt.cacheEnabled : _cacheEnabled;
    _cacheSize = opt.cacheSize || _cacheSize;
    if (_isSupportHistoryState) {
      $(window).on('popstate', _checkMark);
    } else {
      $(window).on('hashchange', _checkMark);
    }
    _checkMark();
    return init = function() {};
  };

  setListener = function(listener, bind) {
    _listener = typeof listener === 'function' ? listener : null;
    return _listenerBind = bind || null;
  };

  setCache = function(mark, data) {
    if (_isValidMark(mark)) {
      return _setCache(mark, data);
    }
  };

  getCache = function(mark) {
    return _cache[_markCacheIndexHash[mark]];
  };

  clearCache = function() {
    _markCacheIndexHash = {};
    return _cache = [];
  };

  setMark = function(mark, opt) {
    opt = opt || {};
    if (opt.title) {
      document.title = opt.title;
    }
    if (mark !== _currentMark && _isValidMark(mark)) {
      _updateCurrentMark(mark);
      if (_isSupportHistoryState) {
        return history[opt.replaceState ? 'replaceState' : 'pushState'](opt.stateObj, opt.title || document.title, '/' + mark);
      } else {
        return location.hash = '!' + mark;
      }
    }
  };

  getMark = function() {
    if (_isSupportHistoryState) {
      return location.pathname.replace(/^\//, '');
    } else {
      return location.hash.replace(/^#!?\/?/, '');
    }
  };

  getPrevMark = function() {
    return _previousMark;
  };

  isSupportHistoryState = function() {
    return _isSupportHistoryState;
  };

  module.exports = {
    init: init,
    setListener: setListener,
    setCache: setCache,
    getCache: getCache,
    clearCache: clearCache,
    setMark: setMark,
    getMark: getMark,
    getPrevMark: getPrevMark,
    isSupportHistoryState: isSupportHistoryState
  };

}).call(this);

});

define('./base-mod', ['require', 'exports', 'module', 'jquery', './core'], function(require, exports, module) {
(function() {
  var $, BaseMod, core;

  $ = require('jquery');

  core = require('./core');

  BaseMod = (function() {
    function BaseMod(modName, contentDom, args, opt) {
      this._modName = modName;
      if (!contentDom) {
        return this;
      }
      this._contentDom = contentDom;
      this._bindEvents();
      this._args = args || [];
      this._opt = opt || {};
      this.init();
      this.render();
    }

    BaseMod.prototype.showNavTab = false;

    BaseMod.prototype.navTab = '';

    BaseMod.prototype.events = {};

    BaseMod.prototype.parentModNames = {
      'home': 1
    };

    BaseMod.prototype._bindEvents = function() {
      return $.each(this.events, (function(_this) {
        return function(k, v) {
          k = k.split(' ');
          return _this._contentDom.on(k.shift(), k.join(' '), _this[v]);
        };
      })(this));
    };

    BaseMod.prototype._unbindEvents = function() {
      return $.each(this.events, (function(_this) {
        return function(k, v) {
          k = k.split(' ');
          return _this._contentDom.off(k.shift(), k.join(' '), _this[v]);
        };
      })(this));
    };

    BaseMod.prototype._ifNotCachable = function(relModName, callback, elseCallback) {
      var relModInst;
      if (typeof this.cachable !== 'undefined') {
        if (this.cachable) {
          return typeof elseCallback === "function" ? elseCallback() : void 0;
        } else {
          return typeof callback === "function" ? callback() : void 0;
        }
      } else {
        relModInst = core.getCached(relModName);
        if (relModInst) {
          if (!relModInst.hasParent(this._modName)) {
            return typeof callback === "function" ? callback() : void 0;
          } else {
            return typeof elseCallback === "function" ? elseCallback() : void 0;
          }
        } else {
          return require(['mod/' + relModName + '/main'], (function(_this) {
            return function(ModClass) {
              relModInst = new ModClass(relModName);
              if (!relModInst.hasParent(_this._modName)) {
                return typeof callback === "function" ? callback() : void 0;
              } else {
                return typeof elseCallback === "function" ? elseCallback() : void 0;
              }
            };
          })(this), (function(_this) {
            return function() {
              if (relModName.indexOf(_this._modName + '/') !== 0) {
                return typeof callback === "function" ? callback() : void 0;
              } else {
                return typeof elseCallback === "function" ? elseCallback() : void 0;
              }
            };
          })(this));
        }
      }
    };

    BaseMod.prototype._afterFadeIn = function(relModInst) {};

    BaseMod.prototype._afterFadeOut = function(relModName) {
      return this._ifNotCachable(relModName, (function(_this) {
        return function() {
          return _this.destroy();
        };
      })(this));
    };

    BaseMod.prototype._renderHeader = function(data) {
      if (this._contentDom) {
        if (typeof data === 'string') {
          return $('> .sb-mod__header', this._contentDom).html(data);
        } else {
          return $('> .sb-mod__header', this._contentDom).html(this._headerTpl.render(data));
        }
      }
    };

    BaseMod.prototype._renderBody = function(data) {
      if (this._contentDom) {
        if (typeof data === 'string') {
          return $('> .sb-mod__body', this._contentDom).html(data);
        } else {
          return $('> .sb-mod__body', this._contentDom).html(this._bodyTpl.render(data));
        }
      }
    };

    BaseMod.prototype._renderFixedFooter = function(data) {
      if (this._contentDom) {
        if (typeof data === 'string') {
          return $('> .sb-mod__fixed-footer', this._contentDom).html(data).show();
        } else {
          return $('> .sb-mod__fixed-footer', this._contentDom).html(this._fixedFooterTpl.render(data)).show();
        }
      }
    };

    BaseMod.prototype._renderError = function(msg) {
      if (this._contentDom) {
        $('> .sb-mod__body', this._contentDom).html(['<div class="sb-mod__body__msg" data-refresh-btn>', '<div class="msg">', msg || G.SVR_ERR_MSG, '</div>', '<div class="refresh"><span class="icon icon-refresh"></span>点击刷新</div>', '</div>'].join(''));
        return $('> .sb-mod__fixed-footer', this._contentDom).hide();
      }
    };

    BaseMod.prototype.render = function() {
      if (this._headerTpl) {
        this._renderHeader({
          args: this._args,
          opt: this._opt
        });
      }
      if (this._bodyTpl) {
        this._renderBody({
          args: this._args,
          opt: this._opt
        });
      }
      if (this._fixedFooterTpl) {
        return this._renderFixedFooter({
          args: this._args,
          opt: this._opt
        });
      }
    };

    BaseMod.prototype.init = function() {};

    BaseMod.prototype.$ = function(s) {
      return $(s, this._contentDom);
    };

    BaseMod.prototype.getModName = function() {
      return this._modName;
    };

    BaseMod.prototype.getArgs = function() {
      return this._args;
    };

    BaseMod.prototype.update = function(args, opt) {
      this._args = args || this._args;
      this._opt = opt || this._opt;
      return this.refresh();
    };

    BaseMod.prototype.refresh = function() {
      this.scrollToTop();
      core.scroll(0);
      return this.render();
    };

    BaseMod.prototype.scrollToTop = function() {
      return $('> .sb-mod__body', this._contentDom).scrollTop(0);
    };

    BaseMod.prototype.isRenderred = function() {
      return $('[data-sb-mod-not-renderred]', this._contentDom).length === 0;
    };

    BaseMod.prototype.hasParent = function(modName) {
      var k, ref, res, v;
      res = this._modName.indexOf(modName + '/') === 0;
      if (!res) {
        ref = this.parentModNames;
        for (k in ref) {
          v = ref[k];
          res = modName === k || k.indexOf(modName + '/') === 0;
          if (res) {
            break;
          }
        }
      }
      return res;
    };

    BaseMod.prototype.fadeIn = function(relModInst, animateType) {
      return core.fadeIn(this, this._contentDom, relModInst != null ? relModInst.hasParent(this._modName) : void 0, animateType, (function(_this) {
        return function() {
          return _this._afterFadeIn(relModInst);
        };
      })(this));
    };

    BaseMod.prototype.fadeOut = function(relModName, animateType) {
      this._contentDom.attr('data-sb-scene', (parseInt(this._contentDom.attr('data-sb-scene')) || 0) + 1);
      this._ifNotCachable(relModName, (function(_this) {
        return function() {
          return core.removeCache(_this._modName);
        };
      })(this));
      return core.fadeOut(this, this._contentDom, this.hasParent(relModName), animateType, (function(_this) {
        return function() {
          return _this._afterFadeOut(relModName);
        };
      })(this));
    };

    BaseMod.prototype.captureScene = function(callback) {
      var scene;
      if (this._contentDom) {
        scene = parseInt(this._contentDom.attr('data-sb-scene')) || 0;
        return callback((function(_this) {
          return function(callback) {
            var newScene;
            if (_this._contentDom) {
              newScene = parseInt(_this._contentDom.attr('data-sb-scene')) || 0;
              if (newScene === scene) {
                return callback();
              }
            }
          };
        })(this));
      }
    };

    BaseMod.prototype.destroy = function() {
      core.removeCache(this._modName);
      this._unbindEvents();
      this._contentDom.remove();
      return this._contentDom = null;
    };

    return BaseMod;

  })();

  module.exports = BaseMod;

}).call(this);

});