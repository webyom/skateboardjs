(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jquery"));
	else if(typeof define === 'function' && define.amd)
		define(["jquery"], factory);
	else if(typeof exports === 'object')
		exports["Skateboard"] = factory(require("jquery"));
	else
		root["Skateboard"] = factory(root["$"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 4);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

var $, _constructContentDom, _container, _cssProps, _currentMark, _currentModName, _getParamsObj, _getParamsStr, _init, _isElectron, _isSameOrigin, _isSameParams, _loadId, _modCache, _onAfterViewChange, _opt, _previousMark, _previousModName, _requestAnimationFrame, _requireMod, _scrollTop, _switchNavTab, _trimSlash, _viewChangeInfo, _viewId, ajaxHistory, core,
  hasProp = {}.hasOwnProperty;

$ = __webpack_require__(1);

ajaxHistory = __webpack_require__(2);

_modCache = {};

_currentMark = null;

_currentModName = '';

_previousMark = null;

_previousModName = '';

_scrollTop = 0;

_viewChangeInfo = null;

_opt = {};

_container = $(document.body);

_viewId = 0;

_loadId = 0;

_cssProps = (function() {
  var el, p, props;
  el = document.createElement('div');
  props = {
    webkitTransition: ['webkitTransitionEnd', '-webkit-transition', '-webkit-transform'],
    transition: ['transitionend', 'transition', 'transform']
  };
  for (p in props) {
    if (el.style[p] !== void 0) {
      return props[p];
    }
  }
  return null;
})();

_requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || function(callback) {
  return setTimeout(callback, 16);
};

_isElectron = !!(typeof window.require === "function" ? window.require('electron') : void 0);

_requireMod = function(modName, callback, errCallback) {
  var err, path;
  path = _opt.modBase + modName + '/main';
  if (_isElectron) {
    try {
      return callback(window.require(path));
    } catch (error) {
      err = error;
      return errCallback(err);
    }
  } else {
    return window.require([path], callback, errCallback);
  }
};

_trimSlash = function(str) {
  if (str) {
    return str.replace(/^\/+|\/+$/g, '');
  } else {
    return '';
  }
};

_getParamsStr = function(params) {
  var key, tmp, type, val;
  if (!params) {
    return '';
  } else {
    type = typeof params;
    if (type === 'string') {
      return params;
    } else {
      tmp = [];
      for (key in params) {
        if (!hasProp.call(params, key)) continue;
        val = params[key];
        if (typeof val === 'string') {
          tmp.push(key + "=" + val);
        }
      }
      return tmp.join('&');
    }
  }
};

_getParamsObj = function(paramsStr) {
  var i, key, len, params, ref, tmp, type, val;
  params = {};
  if (paramsStr) {
    type = typeof paramsStr;
    if (type === 'string') {
      ref = paramsStr.split('&');
      for (i = 0, len = ref.length; i < len; i++) {
        tmp = ref[i];
        tmp = tmp.split('=');
        params[tmp[0]] = tmp[1];
      }
    } else {
      for (key in paramsStr) {
        if (!hasProp.call(paramsStr, key)) continue;
        val = paramsStr[key];
        if (typeof val === 'string') {
          params[key] = val;
        }
      }
    }
  }
  return params;
};

_isSameParams = function(params1, params2) {
  return _getParamsStr(params1) === _getParamsStr(params2);
};

_switchNavTab = function(modInst) {
  var tabName;
  if (_opt.switchNavTab) {
    return _opt.switchNavTab(modInst);
  } else {
    tabName = modInst.navTab;
    if (typeof tabName === 'function') {
      tabName = tabName();
    }
    $('app-nav [data-tab]', _container).removeClass('active');
    return $('app-nav [data-tab="' + tabName + '"]', _container).addClass('active');
  }
};

_onAfterViewChange = function(info, modInst) {
  var bodyClassName, modClassName;
  info.toModInst = modInst;
  modClassName = 'body-sb-mod--' + modInst._modName.replace(/\//g, '__');
  bodyClassName = document.body.className.replace(/\bbody-sb-mod--\S+/, modClassName);
  if (/\bsb-show-nav\b/.test(bodyClassName)) {
    if (!modInst.showNavTab) {
      bodyClassName = bodyClassName.replace(/\s*\bsb-show-nav\b/, '');
    }
  } else if (modInst.showNavTab) {
    bodyClassName = bodyClassName + ' sb-show-nav';
  }
  document.body.className = bodyClassName;
  if (_opt.onAfterViewChange) {
    return _opt.onAfterViewChange(info);
  }
};

_constructContentDom = function(modName, params, opt) {
  var contentDom, titleTpl;
  if (params == null) {
    params = {};
  }
  if (_opt.constructContentDom) {
    contentDom = _opt.constructContentDom(modName, params, opt);
  } else {
    try {
      titleTpl = window.require(_opt.modBase + modName + '/title.tpl.html');
    } catch (error) {}
    contentDom = $([
      '<div class="sb-mod sb-mod--' + modName.replace(/\//g, '__') + '" data-sb-mod="' + modName + '" data-sb-scene="0">', '<header class="sb-mod__header">', titleTpl ? titleTpl.render({
        params: params,
        opt: opt
      }) : '<h1 class="title"></h1>', '</header>', '<div class="sb-mod__body" onscroll="require(\'app\').mod.scroll(this.scrollTop);">', '<div class="sb-mod__body__msg" data-sb-mod-not-renderred>', _opt.loadingMsg || '内容正在赶来，请稍候...', '</div>', '</div>', '<div class="sb-mod__fixed-footer" style="display: none;">', '</div>', '</div>'
    ].join('')).prependTo(_container);
  }
  return contentDom;
};

_isSameOrigin = function(link) {
  if (link.origin) {
    if (link.origin === location.origin) {
      return true;
    } else {
      return false;
    }
  }
  return (link.href + '/').indexOf(location.origin + '/') === 0;
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
    exclamationMark: _opt.exclamationMark,
    isSupportHistoryState: _opt.isSupportHistoryState
  });
  t = new Date();
  $(document.body).on('click', function(e) {
    var el, mark, ref, tmp;
    el = e.target;
    mark;
    t = new Date();
    if (el.tagName !== 'A') {
      el = $(el).closest('a')[0];
    }
    if (el && el.tagName === 'A' && _isSameOrigin(el) && !el.target) {
      if ((el.pathname || '/') === location.pathname && el.hash) {
        mark = el.hash.replace(/^#!?\/*/, '');
        if (mark && el.hash.length - mark.length < 2) {
          return;
        }
      } else {
        mark = ((ref = el.pathname) != null ? ref.replace(/^\/+/, '') : void 0) || '';
        if (el.search) {
          mark += el.search;
        }
      }
      if (mark.indexOf(':back') === 0) {
        e.preventDefault();
        tmp = mark.split(':back:');
        if (tmp.length > 1) {
          return core.back(tmp[1]);
        } else {
          return history.back();
        }
      } else if (_opt.modPrefix === '' || mark.indexOf(_opt.modPrefix + '/') === 0) {
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
      _opt.modPrefix = '';
    }
    _opt.modPrefix = _trimSlash(_opt.modPrefix);
    return _init();
  },
  modCacheable: function() {
    return _opt.modCacheable;
  },
  getModBase: function() {
    return _opt.modBase;
  },
  getReact: function() {
    var ref, ref1, ref2, ref3;
    if (!((ref = _opt.react) != null ? ref.React : void 0)) {
      _opt.react = Object.assign({
        React: window.React,
        createElement: (ref1 = window.React) != null ? ref1.createElement : void 0,
        ReactDOM: window.ReactDOM,
        render: (ref2 = window.ReactDOM) != null ? ref2.render : void 0,
        unmountComponentAtNode: (ref3 = window.ReactDOM) != null ? ref3.unmountComponentAtNode : void 0
      }, _opt.react);
    }
    return _opt.react;
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
  fadeIn: function(modInst, contentDom, relation, from, animateType, cb) {
    var callback, cssObj, duration, fromHistory, percentage, ref, ref1, ref2, ref3, res, sd, ttf;
    fromHistory = from === 'history';
    if (typeof _opt.onBeforeFadeIn === "function") {
      _opt.onBeforeFadeIn(modInst);
    }
    if (_opt.fadeIn) {
      return _opt.fadeIn(modInst, contentDom, relation, from, animateType, cb);
    } else {
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
            zIndex: '3'
          });
        }
        return typeof cb === "function" ? cb() : void 0;
      };
      if (animateType === 'fade' || animateType === 'fadeIn') {
        if (_cssProps) {
          cssObj = {
            opacity: '0'
          };
          cssObj[_cssProps[1]] = 'none';
          cssObj[_cssProps[2]] = 'translateZ(0)';
          contentDom.css(cssObj).show();
          contentDom[0].offsetTop;
          _requestAnimationFrame(function() {
            cssObj = {};
            cssObj[_cssProps[1]] = "opacity " + (duration / 1000) + "s " + ttf;
            cssObj['opacity'] = '1';
            contentDom.one(_cssProps[0], callback);
            return contentDom.css(cssObj);
          });
        } else {
          contentDom.css({
            opacity: '0'
          });
          contentDom.show();
          _requestAnimationFrame(function() {
            return contentDom.animate({
              opacity: '1'
            }, duration, ttf, callback);
          });
        }
      } else if (animateType === 'slide' && relation !== 'tab') {
        sd = $('[data-slide-direction]', contentDom).attr('data-slide-direction');
        percentage = Math.min(Math.max(0, (ref3 = _opt.animate) != null ? ref3.slideOutPercent : void 0), 100);
        if (_cssProps) {
          cssObj = {};
          cssObj[_cssProps[1]] = 'none';
          if (sd === 'vu' || sd === 'vd') {
            cssObj.zIndex = '3';
            cssObj[_cssProps[2]] = 'translate3d(0, ' + (sd === 'vd' ? '-' : '') + '100%, 0)';
          } else {
            cssObj.zIndex = fromHistory ? '1' : '3';
            cssObj[_cssProps[2]] = 'translate3d(' + (fromHistory ? '-' + percentage : '100') + '%, 0, 0)';
          }
          contentDom.css(cssObj).show();
          contentDom[0].offsetTop;
          _requestAnimationFrame(function() {
            cssObj = {};
            cssObj[_cssProps[1]] = _cssProps[2] + " " + (duration / 1000) + "s " + ttf;
            cssObj[_cssProps[2]] = 'translate3d(0, 0, 0)';
            contentDom.one(_cssProps[0], callback);
            return contentDom.css(cssObj);
          });
        } else {
          if (sd === 'vu' || sd === 'vd') {
            contentDom.css({
              zIndex: '3',
              left: '0',
              top: (sd === 'vd' ? '-' : '') + '100%'
            });
          } else {
            contentDom.css({
              zIndex: fromHistory ? '1' : '3',
              left: (fromHistory ? '-' + percentage : '100') + '%',
              top: '0'
            });
          }
          contentDom.show();
          _requestAnimationFrame(function() {
            return contentDom.animate({
              left: '0',
              top: '0'
            }, duration, ttf, callback);
          });
        }
      } else {
        contentDom.show();
        callback();
      }
      return res;
    }
  },
  fadeOut: function(modInst, contentDom, relation, from, animateType, cb) {
    var callback, duration, fromHistory, percentage, ref, ref1, ref2, ref3, res, sd, ttf, zIndex;
    fromHistory = from === 'history';
    if (typeof _opt.onBeforeFadeOut === "function") {
      _opt.onBeforeFadeOut(modInst);
    }
    if (_opt.fadeOut) {
      return _opt.fadeOut(modInst, contentDom, relation, from, animateType, cb);
    } else {
      res = '';
      animateType = animateType || ((ref = _opt.animate) != null ? ref.type : void 0);
      ttf = ((ref1 = _opt.animate) != null ? ref1.timingFunction : void 0) || 'linear';
      duration = ((ref2 = _opt.animate) != null ? ref2.duration : void 0) || 300;
      callback = function() {
        if (contentDom.attr('data-sb-mod') !== _currentModName) {
          contentDom.hide();
        }
        return typeof cb === "function" ? cb() : void 0;
      };
      if (animateType === 'fade') {
        if (_cssProps) {
          _requestAnimationFrame(function() {
            var cssObj;
            cssObj = {};
            cssObj[_cssProps[1]] = "opacity " + (duration / 1000) + "s " + ttf;
            cssObj[_cssProps[2]] = 'translateZ(0)';
            cssObj['opacity'] = '0';
            contentDom.one(_cssProps[0], callback);
            return contentDom.css(cssObj);
          });
        } else {
          _requestAnimationFrame(function() {
            return contentDom.animate({
              opacity: '0'
            }, duration, ttf, callback);
          });
        }
      } else if (animateType === 'slide' && relation !== 'tab') {
        sd = $('[data-slide-direction]', contentDom).attr('data-slide-direction');
        zIndex = '2';
        percentage = Math.min(Math.max(0, (ref3 = _opt.animate) != null ? ref3.slideOutPercent : void 0), 100);
        if (sd === 'vu' || sd === 'vd') {
          res = 'fade';
          zIndex = '4';
        }
        if (_cssProps) {
          _requestAnimationFrame(function() {
            var cssObj;
            cssObj = {
              zIndex: zIndex
            };
            cssObj[_cssProps[1]] = _cssProps[2] + " " + (duration / 1000) + "s " + ttf;
            if (sd === 'vu' || sd === 'vd') {
              cssObj[_cssProps[2]] = 'translate3d(0, ' + (sd === 'vd' ? -100 : 100) + '%, 0)';
            } else {
              cssObj[_cssProps[2]] = 'translate3d(' + (fromHistory ? '100' : '-' + percentage) + '%, 0, 0)';
            }
            contentDom.one(_cssProps[0], callback);
            return contentDom.css(cssObj);
          });
        } else {
          contentDom.css({
            zIndex: zIndex,
            left: '0',
            top: '0'
          });
          _requestAnimationFrame(function() {
            if (sd === 'vu' || sd === 'vd') {
              return contentDom.animate({
                top: (sd === 'vd' ? -100 : 100) + '%'
              }, duration, ttf, callback);
            } else {
              return contentDom.animate({
                left: (fromHistory ? '100' : '-' + percentage) + '%'
              }, duration, ttf, callback);
            }
          });
        }
      } else {
        callback();
      }
      return res;
    }
  },
  view: function(mark, opt) {
    var contentDom, loadMod, markParts, modInst, modName, pModInst, pModName, params, viewId;
    mark = _trimSlash(mark);
    opt = opt || {};
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
    markParts = mark.split('?');
    params = $.extend(_getParamsObj(markParts[1]), _getParamsObj(opt.params));
    pModName = _currentModName;
    pModInst = _modCache[pModName];
    if (_opt.modPrefix === '' || mark.indexOf(_opt.modPrefix + '/') === 0) {
      markParts = markParts[0].split('/-/');
      modName = _trimSlash(markParts[0].replace(_opt.modPrefix, ''));
      if (markParts[1]) {
        params = $.extend(params, markParts[1].split('/'));
      }
    }
    modName = modName || _opt.defaultModName;
    modInst = _modCache[modName];
    _viewChangeInfo = {
      from: opt.from || 'api',
      scrollTop: $(window).scrollTop(),
      loadFromModCache: true,
      fromModName: pModName,
      toModName: modName,
      fromMark: _currentMark,
      toMark: mark,
      fromModInst: pModInst,
      toModInst: modInst,
      params: params,
      opt: opt.modOpt
    };
    if ((typeof _opt.onBeforeViewChange === "function" ? _opt.onBeforeViewChange(_viewChangeInfo) : void 0) === false) {
      return;
    }
    if (mark === _currentMark && modName !== 'alert') {
      if (modInst) {
        modInst.refresh();
        _onAfterViewChange(_viewChangeInfo, modInst);
        core.trigger('afterViewChange', _viewChangeInfo);
      }
      return;
    }
    _previousMark = _currentMark;
    _previousModName = _currentModName;
    _currentMark = mark;
    _currentModName = modName;
    _viewId++;
    viewId = _viewId;
    if (modInst && modInst.isRenderred() && modName !== 'alert' && modName === pModName) {
      modInst.update(mark, params, opt.modOpt);
      _onAfterViewChange(_viewChangeInfo, modInst);
      core.trigger('afterViewChange', _viewChangeInfo);
    } else if (modInst && modInst.isRenderred() && modName !== 'alert' && !opt.modOpt && (!modInst.viewed || _viewChangeInfo.from === 'history' || _opt.alwaysUseCache || modInst.alwaysUseCache || opt.useCache) && _isSameParams(modInst.getParams(), params)) {
      modInst.fadeIn(pModInst, opt.from, pModInst != null ? pModInst.fadeOut(modName, opt.from) : void 0, function() {
        _switchNavTab(modInst);
        _onAfterViewChange(_viewChangeInfo, modInst);
        return core.trigger('afterViewChange', _viewChangeInfo);
      });
    } else {
      _viewChangeInfo.loadFromModCache = false;
      core.removeCache(modName);
      if (modInst != null) {
        modInst.destroy();
      }
      $('[data-sb-mod="' + modName + '"]', _container).remove();
      loadMod = function(modName, contentDom, params) {
        return _requireMod(modName, function(com) {
          var e;
          if (viewId === _viewId && !_modCache[modName]) {
            try {
              modInst = _modCache[modName] = new com.Mod(mark, modName, contentDom, params, opt.modOpt);
              modInst.render();
              if (typeof _opt.onFirstRender === "function") {
                _opt.onFirstRender();
              }
              return _opt.onFirstRender = null;
            } catch (error) {
              e = error;
              if (typeof console !== "undefined" && console !== null) {
                if (typeof console.error === "function") {
                  console.error(e.stack);
                }
              }
              if (_opt.onInitModFail) {
                return _opt.onInitModFail(mark, modName, params, opt.modOpt, 'view', viewId === _viewId);
              } else {
                throw e;
              }
            } finally {
              if (modInst) {
                modInst._afterFadeIn(pModInst);
                _switchNavTab(modInst);
                _onAfterViewChange(_viewChangeInfo, modInst);
                core.trigger('afterViewChange', _viewChangeInfo);
              } else {
                contentDom.remove();
              }
            }
          } else {
            return contentDom.remove();
          }
        }, function() {
          var ref;
          contentDom.remove();
          if (_opt.onLoadModFail) {
            return _opt.onLoadModFail(mark, modName, params, opt.modOpt, 'view', viewId === _viewId);
          } else if (modName !== 'alert') {
            if (viewId === _viewId) {
              return core.showAlert({
                type: 'error',
                subType: 'load_mod_fail',
                relModName: modName
              }, {
                holdMark: true
              });
            }
          } else {
            return alert('Failed to load module "' + (((ref = opt.modOpt) != null ? ref.relModName : void 0) || '') + '"');
          }
        });
      };
      if (_opt.initContentDom && modName === _opt.defaultModName) {
        contentDom = $(_opt.initContentDom);
        contentDom.attr('data-mod-name', modName);
        _opt.initContentDom = null;
        loadMod(modName, contentDom, params);
      } else {
        if (_opt.initContentDom) {
          $(_opt.initContentDom).remove();
          _opt.initContentDom = null;
        }
        contentDom = _constructContentDom(modName, params, opt.modOpt);
        core.fadeIn(null, contentDom, pModInst != null ? pModInst.getRelation(modName) : void 0, opt.from, pModInst != null ? pModInst.fadeOut(modName, opt.from) : void 0, function() {
          return loadMod(modName, contentDom, params);
        });
      }
    }
    if (!opt.holdMark) {
      return ajaxHistory.setMark(mark, {
        replaceState: opt.replaceState
      });
    }
  },
  load: function(mark, opt, onLoad) {
    var contentDom, loadId, loadMod, markParts, modInst, modName, params, viewId;
    mark = _trimSlash(mark);
    opt = opt || {};
    markParts = mark.split('?');
    params = $.extend(_getParamsObj(markParts[1]), _getParamsObj(opt.params));
    if (_opt.modPrefix === '' || mark.indexOf(_opt.modPrefix + '/') === 0) {
      markParts = markParts[0].split('/-/');
      modName = _trimSlash(markParts[0].replace(_opt.modPrefix, ''));
      if (markParts[1]) {
        params = $.extend(params, markParts[1].split('/'));
      }
    }
    modName = modName || _opt.defaultModName;
    modInst = _modCache[modName];
    if (onLoad) {
      _loadId++;
    }
    viewId = _viewId;
    loadId = _loadId;
    if (modName === _currentModName || modInst && modInst.isRenderred() && modName !== 'alert' && !opt.modOpt && (_opt.alwaysUseCache || modInst.alwaysUseCache) && _isSameParams(modInst.getParams(), params)) {
      return typeof onLoad === "function" ? onLoad() : void 0;
    } else {
      core.removeCache(modName);
      if (modInst != null) {
        modInst.destroy();
      }
      $('[data-sb-mod="' + modName + '"]', _container).remove();
      loadMod = function(modName, contentDom, params) {
        return _requireMod(modName, function(com) {
          var e;
          if (viewId === _viewId && loadId === _loadId && !_modCache[modName]) {
            try {
              modInst = _modCache[modName] = new com.Mod(mark, modName, contentDom, params, opt.modOpt, function() {
                if (viewId === _viewId && loadId === _loadId) {
                  return typeof onLoad === "function" ? onLoad() : void 0;
                }
              });
              return modInst.render();
            } catch (error) {
              e = error;
              contentDom.remove();
              if (typeof console !== "undefined" && console !== null) {
                if (typeof console.error === "function") {
                  console.error(e.stack);
                }
              }
              if (_opt.onInitModFail) {
                return _opt.onInitModFail(mark, modName, params, opt.modOpt, 'load', viewId === _viewId && loadId === _loadId);
              } else {
                throw e;
              }
            }
          } else {
            return contentDom.remove();
          }
        }, function() {
          var ref;
          if (onLoad) {
            if (_opt.onLoadModFail) {
              contentDom.remove();
              return _opt.onLoadModFail(mark, modName, params, opt.modOpt, 'load', viewId === _viewId && loadId === _loadId);
            } else if (modName !== 'alert') {
              contentDom.remove();
              if (viewId === _viewId && loadId === _loadId) {
                return core.showAlert({
                  type: 'error',
                  subType: 'load_mod_fail',
                  relModName: modName
                }, {});
              }
            } else {
              return alert('Failed to load module "' + (((ref = opt.modOpt) != null ? ref.relModName : void 0) || '') + '"');
            }
          }
        });
      };
      contentDom = _constructContentDom(modName, params, opt.modOpt);
      return loadMod(modName, contentDom, params);
    }
  },
  back: function(mark) {
    var markParts, modInst, modName, params;
    mark = _trimSlash(mark);
    markParts = mark.split('?');
    params = markParts[1];
    if (_opt.modPrefix === '' || mark.indexOf(_opt.modPrefix + '/') === 0) {
      markParts = markParts[0].split('/-/');
      modName = _trimSlash(markParts[0].replace(_opt.modPrefix, ''));
      params = params || markParts[1];
    }
    if (modName) {
      modInst = _modCache[modName];
      if (modInst) {
        if (params) {
          if (mark === modInst.getMark()) {
            return core.view(mark, {
              from: 'history'
            });
          } else {
            return core.view(mark, {
              from: 'link'
            });
          }
        } else {
          return core.view(modInst.getMark(), {
            from: 'history'
          });
        }
      } else {
        return core.view(mark, {
          from: 'link'
        });
      }
    } else {
      return history.back();
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
    return core.view(_opt.modPrefix + '/' + (_opt.alertModName || 'alert') + '?t=' + (new Date().getTime()), viewOpt);
  },
  captureScene: function() {
    var modInst;
    modInst = _modCache[_currentMark];
    if (modInst) {
      return modInst.captureScene();
    } else {
      return {
        captured: -1,
        getCurrent: function() {
          return -2;
        },
        isChanged: function() {
          return true;
        },
        doInScene: function() {}
      };
    }
  }
});

module.exports = core;


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

var $, _checkMark, _currentMark, _exclamationMark, _isSupportHistoryState, _isValidMark, _listener, _listenerBind, _previousMark, _updateCurrentMark, getMark, getPrevMark, init, isSupportHistoryState, push, setListener, setMark, to;

$ = __webpack_require__(1);

_previousMark = void 0;

_currentMark = void 0;

_listener = null;

_listenerBind = null;

_exclamationMark = '';

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

_isValidMark = function(mark) {
  return typeof mark === 'string' && !/^[#!]/.test(mark);
};

init = function(opt) {
  opt = opt || {};
  if (opt.exclamationMark) {
    _exclamationMark = '!';
  }
  _isSupportHistoryState = typeof opt.isSupportHistoryState !== 'undefined' ? opt.isSupportHistoryState : _isSupportHistoryState;
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

to = function(path) {
  path = path.replace(/^\/*/, '/');
  if (_isSupportHistoryState) {
    return path;
  } else {
    return '#' + path;
  }
};

push = function(mark) {
  var core;
  core = __webpack_require__(0);
  return core.view(mark);
};

setMark = function(mark, opt) {
  mark = getMark(mark);
  opt = opt || {};
  if (opt.title) {
    document.title = opt.title;
  }
  if (mark !== _currentMark && _isValidMark(mark)) {
    _updateCurrentMark(mark);
    if (_isSupportHistoryState) {
      return history[opt.replaceState ? 'replaceState' : 'pushState'](opt.stateObj, opt.title || document.title, '/' + mark);
    } else {
      return location.hash = _exclamationMark + '/' + mark;
    }
  }
};

getMark = function(mark) {
  if (mark) {
    return mark.replace(/^\/+/, '');
  } else if (_isSupportHistoryState) {
    return location.pathname.replace(/^\/+/, '');
  } else {
    return location.hash.replace(/^#!?\/*/, '');
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
  to: to,
  push: push,
  setMark: setMark,
  getMark: getMark,
  getPrevMark: getPrevMark,
  isSupportHistoryState: isSupportHistoryState
};


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

var $, BaseMod, core,
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

$ = __webpack_require__(1);

core = __webpack_require__(0);

BaseMod = (function() {
  function BaseMod(mark, modName, contentDom, params, opt, onFirstRender) {
    this._mark = mark;
    this._modName = modName;
    if (!contentDom) {
      return this;
    }
    this._contentDom = contentDom;
    this._bindEvents();
    this._params = params || {};
    this._opt = opt || {};
    this._onFirstRender = onFirstRender;
    this.init();
  }

  BaseMod.prototype.viewed = false;

  BaseMod.prototype.showNavTab = false;

  BaseMod.prototype.navTab = '';

  BaseMod.prototype.tabModNames = [];

  BaseMod.prototype.events = {};

  BaseMod.prototype.parentModNames = {
    'home': 1
  };

  BaseMod.prototype.headerTpl = '';

  BaseMod.prototype.bodyTpl = '';

  BaseMod.prototype.fixedFooterTpl = '';

  BaseMod.prototype.moduleClassNames = '';

  BaseMod.prototype.ReactComponent = null;

  BaseMod.prototype._reactComInst = null;

  BaseMod.prototype._bindEvents = function() {
    var k, ref, results, v;
    ref = this.events;
    results = [];
    for (k in ref) {
      if (!hasProp.call(ref, k)) continue;
      v = ref[k];
      k = k.split(' ');
      results.push(this._contentDom.on(k.shift(), k.join(' '), this[v]));
    }
    return results;
  };

  BaseMod.prototype._unbindEvents = function() {
    var k, ref, results, v;
    ref = this.events;
    results = [];
    for (k in ref) {
      if (!hasProp.call(ref, k)) continue;
      v = ref[k];
      k = k.split(' ');
      results.push(this._contentDom.off(k.shift(), k.join(' '), this[v]));
    }
    return results;
  };

  BaseMod.prototype._ifNotCachable = function(relModName, callback, elseCallback) {
    var cachable, relModInst;
    cachable = typeof this.cachable !== 'undefined' ? this.cachable : core.modCacheable();
    if (typeof cachable !== 'undefined') {
      if (cachable) {
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
        return window.require([core.getModBase() + relModName + '/main'], (function(_this) {
          return function(com) {
            relModInst = new com.Mod(relModName, relModName);
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

  BaseMod.prototype._afterFadeIn = function(relModInst) {
    return this.viewed = true;
  };

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
        return $('> .sb-mod__header', this._contentDom).html(this.headerTpl.render(data));
      }
    }
  };

  BaseMod.prototype._renderBody = function(data) {
    if (this._contentDom) {
      if (typeof data === 'string') {
        return $('> .sb-mod__body', this._contentDom).html(data);
      } else {
        return $('> .sb-mod__body', this._contentDom).html(this.bodyTpl.render(data));
      }
    }
  };

  BaseMod.prototype._renderFixedFooter = function(data) {
    if (this._contentDom) {
      if (typeof data === 'string') {
        return $('> .sb-mod__fixed-footer', this._contentDom).html(data).show();
      } else {
        return $('> .sb-mod__fixed-footer', this._contentDom).html(this.fixedFooterTpl.render(data)).show();
      }
    }
  };

  BaseMod.prototype._renderError = function(msg) {
    if (this._contentDom) {
      $('> .sb-mod__body', this._contentDom).html(['<div class="sb-mod__body__msg" data-refresh-btn>', '<div class="msg">', msg || G.SVR_ERR_MSG, '</div>', '<div class="refresh"><span class="icon icon-refresh"></span>点击刷新</div>', '</div>'].join(''));
      return $('> .sb-mod__fixed-footer', this._contentDom).hide();
    }
  };

  BaseMod.prototype._onRender = function() {
    if (typeof this._onFirstRender === "function") {
      this._onFirstRender();
    }
    return this._onFirstRender = null;
  };

  BaseMod.prototype.render = function() {
    var ReactComponent, container, ele, react, ref, route;
    if (typeof this.moduleClassNames === 'function') {
      this._contentDom.addClass(this.moduleClassNames());
    } else if (this.moduleClassNames) {
      this._contentDom.addClass(this.moduleClassNames);
    }
    if (this.ReactComponent) {
      react = core.getReact();
      route = {
        mark: this._mark,
        path: this._modName,
        params: this._params,
        opt: this._opt
      };
      container = this._contentDom[0];
      if (this.isRenderred()) {
        if ((ref = this._reactComInst) != null ? ref.onSbModUpdate : void 0) {
          this._reactComInst.onSbModUpdate({
            route: route
          });
          return;
        }
        if (!react.unmountComponentAtNode) {
          return;
        }
        react.unmountComponentAtNode.call(react.ReactDOM, container);
      } else {
        container.innerHTML = '';
      }
      ReactComponent = this.ReactComponent;
      if (react.getReactComponent) {
        ReactComponent = react.getReactComponent(ReactComponent);
      }
      ele = react.createElement.call(react.React, ReactComponent, {
        moduleClassNames: this.moduleClassNames,
        route: route,
        sbModInst: this
      });
      this._reactComInst = react.render.call(react.ReactDOM, ele, container);
    } else {
      if (this.headerTpl) {
        this._renderHeader({
          params: this._params,
          opt: this._opt
        });
      }
      if (this.bodyTpl) {
        this._renderBody({
          params: this._params,
          opt: this._opt
        });
      }
      if (this.fixedFooterTpl) {
        this._renderFixedFooter({
          params: this._params,
          opt: this._opt
        });
      }
    }
    return this._onRender();
  };

  BaseMod.prototype.init = function() {};

  BaseMod.prototype.$ = function(s) {
    return $(s, this._contentDom);
  };

  BaseMod.prototype.getMark = function() {
    return this._mark;
  };

  BaseMod.prototype.getModName = function() {
    return this._modName;
  };

  BaseMod.prototype.getOpt = function() {
    return this._opt;
  };

  BaseMod.prototype.getParams = function() {
    return this._params;
  };

  BaseMod.prototype.update = function(mark, params, opt) {
    this._mark = mark;
    this._params = params || this._params;
    this._opt = opt || this._opt;
    return this.refresh();
  };

  BaseMod.prototype.refresh = function() {
    this.scrollToTop();
    core.scroll(0);
    return this.render();
  };

  BaseMod.prototype.scrollToTop = function() {
    var dom;
    dom = this.$('.sb-mod__body');
    if (!dom.length) {
      dom = this._contentDom;
    }
    return dom.scrollTop(0);
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
        if (!hasProp.call(ref, k)) continue;
        v = ref[k];
        res = modName === k || k.indexOf(modName + '/') === 0;
        if (res) {
          break;
        }
      }
    }
    return res;
  };

  BaseMod.prototype.hasTab = function(modName) {
    return indexOf.call(this.tabModNames, modName) >= 0;
  };

  BaseMod.prototype.getRelation = function(modName) {
    var relation;
    relation = '';
    if (this.hasTab(modName)) {
      relation = 'tab';
    } else if (this.hasParent(modName)) {
      relation = 'parent';
    }
    return relation;
  };

  BaseMod.prototype.fadeIn = function(relModInst, from, animateType, cb) {
    return core.fadeIn(this, this._contentDom, relModInst != null ? relModInst.getRelation(this._modName) : void 0, from, animateType, (function(_this) {
      return function() {
        _this._afterFadeIn(relModInst);
        return typeof cb === "function" ? cb() : void 0;
      };
    })(this));
  };

  BaseMod.prototype.fadeOut = function(relModName, from, animateType, cb) {
    this._contentDom.attr('data-sb-scene', (parseInt(this._contentDom.attr('data-sb-scene')) || 0) + 1);
    this._ifNotCachable(relModName, (function(_this) {
      return function() {
        return core.removeCache(_this._modName);
      };
    })(this));
    return core.fadeOut(this, this._contentDom, this.getRelation(relModName), from, animateType, (function(_this) {
      return function() {
        _this._afterFadeOut(relModName);
        return typeof cb === "function" ? cb() : void 0;
      };
    })(this));
  };

  BaseMod.prototype.captureScene = function() {
    var captured, doInScene, getCurrent, isChanged;
    captured = !this._contentDom ? -1 : parseInt(this._contentDom.attr('data-sb-scene')) || 0;
    getCurrent = (function(_this) {
      return function() {
        if (!_this._contentDom) {
          return -2;
        } else {
          return parseInt(_this._contentDom.attr('data-sb-scene')) || 0;
        }
      };
    })(this);
    isChanged = function() {
      return getCurrent() !== captured;
    };
    doInScene = function(callback) {
      if (!isChanged()) {
        return callback();
      }
    };
    return {
      captured: captured,
      getCurrent: getCurrent,
      isChanged: isChanged,
      doInScene: doInScene
    };
  };

  BaseMod.prototype.destroy = function() {
    var react;
    core.removeCache(this._modName);
    this._unbindEvents();
    if (this.ReactComponent) {
      this.ReactComponent = null;
      this._reactComInst = null;
      react = core.getReact();
      if (react.unmountComponentAtNode) {
        react.unmountComponentAtNode.call(react.ReactDOM, this._contentDom[0]);
      }
    }
    this._contentDom.remove();
    return this._contentDom = null;
  };

  return BaseMod;

})();

module.exports = BaseMod;


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

var BaseMod, core, history;

core = __webpack_require__(0);

history = __webpack_require__(2);

BaseMod = __webpack_require__(3);

module.exports = {
  core: core,
  history: history,
  BaseMod: BaseMod
};


/***/ })
/******/ ]);
});