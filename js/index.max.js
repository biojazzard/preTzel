/*
 * @namespace APPBIO
 *
 * @author Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
*/


(function() {
  var APPBIO,
    _this = this;

  APPBIO = {
    OPTIONS: {
      NAME: 'pretzel.com',
      DESC: '0.4g'
    },
    CONFIG: {
      PARAM: {
        VERSION: '0.1',
        DATE: '01.07.2013'
      }
    },
    init: function() {
      this.Script.init();
    }
  };

  /*
   * @namespace APPBIO
   *
   * @author Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
  */


  APPBIO.Script = (function(appbio, $, µ, undefined_) {
    var config, init, position, s, _log;
    s = null;
    position = null;
    config = {
      settings: {
        pretzel: true,
        version: 'static'
      }
    };
    init = function() {
      /*
       # init
      */

      s = config.settings;
      return _log(s.version);
    };
    _log = function(m) {
      return console.log(m);
    };
    return {
      init: init
    };
  })(APPBIO, jQuery, Modernizr);

  /*
   * @namespace APPBIO
   *
   * @author Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
  */


  APPBIO.App = (function(appbio, $, undefined_) {
    return APPBIO.init();
  })(APPBIO, jQuery);

  /*
   * @namespace APPBIO
   *
   * @author Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
  */


  APPBIO = [];

  window.APPBIO = APPBIO;

  /*
   * 
   * http://paulirish.com/2011/requestanimationframe-for-smart-animating/
   * http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
  
   * requestAnimationFrame polyfill by Erik Möller
   * fixes from Paul Irish and Tino Zijdel
   *
   * @refactoring to CofeeScript by Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
  */


  (function() {
    var lastTime, vendor, vendors, _i, _len;
    lastTime = 0;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    _this.raf = function(_v) {
      window.requestAnimationFrame = window[_v + 'RequestAnimationFrame'];
      return window.cancelAnimationFrame = window[_v + 'cancelAnimationFrame'] || window[_v + 'cancelAnimationFrame'];
    };
    for (_i = 0, _len = vendors.length; _i < _len; _i++) {
      vendor = vendors[_i];
      _this.raf(vendor);
    }
    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, id, timeToCall;
        currTime = Date();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        id = window.setTimeout(function() {
          callback(currTime + timeToCall);
        }, timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
    }
    if (!window.cancelAnimationFrame) {
      return window.cancelAnimationFrame = function(id) {
        clearTimeout(id);
      };
    }
  })();

  /*
   # Theme
  */


  (function($) {
    var $document, $window;
    $window = $(window);
    $document = $(document);
    $document.on("flatdoc:ready", function() {
      return $("h2, h3").scrollagent(function(cid, pid, currentElement, previousElement) {
        if (pid) {
          $("[href='#" + pid + "']").removeClass("active");
        }
        if (cid) {
          return $("[href='#" + cid + "']").addClass("active");
        }
      });
    });
    $document.on("flatdoc:ready", function() {
      return $(".menu a").anchorjump();
    });
    $(function() {
      var $card, $header, headerHeight;
      $card = $(".title-card");
      if (!$card.length) {
        return;
      }
      $header = $(".header");
      headerHeight = ($header.length ? $header.outerHeight() : 0);
      $window.on("resize.title-card", function() {
        var height, windowWidth;
        windowWidth = $window.width();
        if (windowWidth < 480) {
          return $card.css("height", "");
        } else {
          height = $window.height();
          return $card.css("height", height - headerHeight);
        }
      }).trigger("resize.title-card");
      return $card.fillsize("> img.bg");
    });
    return $(function() {
      var $sidebar, elTop;
      $sidebar = $(".menubar");
      elTop = void 0;
      return $window.on("resize.sidestick", function() {
        elTop = $sidebar.offset().top;
        return $window.trigger("scroll.sidestick");
      }).on("scroll.sidestick", function() {
        var scrollY;
        scrollY = $window.scrollTop();
        return $sidebar.toggleClass("fixed", scrollY >= elTop);
      }).trigger("resize.sidestick");
    });
  })(jQuery);

  (function($) {
    return $.fn.scrollagent = function(options, callback) {
      var $parent, $sections, current, height, offsets, range;
      if (typeof callback === "undefined") {
        callback = options;
        options = {};
      }
      $sections = $(this);
      $parent = options.parent || $(window);
      offsets = [];
      $sections.each(function(i) {
        var offset;
        offset = ($(this).attr("data-anchor-offset") ? parseInt($(this).attr("data-anchor-offset"), 10) : options.offset || 0);
        return offsets.push({
          top: $(this).offset().top + offset,
          id: $(this).attr("id"),
          index: i,
          el: this
        });
      });
      current = null;
      height = null;
      range = null;
      $(window).on("resize", function() {
        height = $parent.height();
        return range = $(document).height();
      });
      $parent.on("scroll", function() {
        var i, latest, offset, y;
        y = $parent.scrollTop();
        y += height * (0.3 + 0.7 * Math.pow(y / range, 2));
        latest = null;
        for (i in offsets) {
          if (offsets.hasOwnProperty(i)) {
            offset = offsets[i];
            if (offset.top < y) {
              latest = offset;
            }
          }
        }
        if (latest && (!current || (latest.index !== current.index))) {
          callback.call($sections, (latest ? latest.id : null), (current ? current.id : null), (latest ? latest.el : null), (current ? current.el : null));
          return current = latest;
        }
      });
      $(window).trigger("resize");
      $parent.trigger("scroll");
      return this;
    };
  })(jQuery);

  (function($) {
    var defaults;
    defaults = {
      speed: 500,
      offset: 0,
      "for": null,
      parent: null
    };
    $.fn.anchorjump = function(options) {
      var onClick;
      onClick = function(e) {
        var $a, href;
        $a = $(e.target).closest("a");
        if (e.ctrlKey || e.metaKey || e.altKey || $a.attr("target")) {
          return;
        }
        e.preventDefault();
        href = $a.attr("href");
        return $.anchorjump(href, options);
      };
      options = $.extend({}, defaults, options);
      if (options["for"]) {
        return this.on("click", options["for"], onClick);
      } else {
        return this.on("click", onClick);
      }
    };
    return $.anchorjump = function(href, options) {
      var $area, $parent, offset, top;
      options = $.extend({}, defaults, options);
      top = 0;
      if (href !== "#") {
        $area = $(href);
        if (options.parent) {
          $parent = $area.closest(options.parent);
          if ($parent.length) {
            $area = $parent;
          }
        }
        if (!$area.length) {
          return;
        }
        offset = ($area.attr("data-anchor-offset") ? parseInt($area.attr("data-anchor-offset"), 10) : options.offset);
        top = Math.max(0, $area.offset().top + offset);
      }
      $("html, body").animate({
        scrollTop: top
      }, options.speed);
      $("body").trigger("anchor", href);
      if (window.history.pushState) {
        return window.history.pushState({
          href: href
        }, "", href);
      }
    };
  })(jQuery);

  (function($) {
    return $.fn.fillsize = function(selector) {
      var $img, $parent, resize;
      resize = function() {
        var $img;
        if (!$img) {
          $img = $parent.find(selector);
        }
        return $img.each(function() {
          var containerRatio, css, imageRatio, parent;
          if (!this.complete) {
            return;
          }
          $img = $(this);
          parent = {
            height: $parent.innerHeight(),
            width: $parent.innerWidth()
          };
          imageRatio = $img.width() / $img.height();
          containerRatio = parent.width / parent.height;
          css = {
            position: "absolute",
            left: 0,
            top: 0,
            right: "auto",
            bottom: "auto"
          };
          if (imageRatio > containerRatio) {
            css.left = Math.round((parent.width - imageRatio * parent.height) / 2) + "px";
            css.width = "auto";
            css.height = "100%";
          } else {
            css.top = Math.round((parent.height - (parent.width / $img.width() * $img.height())) / 2) + "px";
            css.height = "auto";
            css.width = "100%";
          }
          return $img.css(css);
        });
      };
      $parent = this;
      $img = void 0;
      $(window).resize(resize);
      $(document).on("fillsize", $parent.selector, resize);
      $(function() {
        $(selector, $parent).bind("load", function() {
          return setTimeout(resize, 25);
        });
        return resize();
      });
      return this;
    };
  })(jQuery);

  /*
   * @namespace APPBIO
   *
   * @author Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
  */


}).call(this);
