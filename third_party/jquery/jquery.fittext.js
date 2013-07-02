/*global jQuery */
/*!
 * FitText.js 1.0
 *
 * Copyright 2011, Dave Rupert http://daverupert.com
 * Released under the WTFPL license
 * http://sam.zoy.org/wtfpl/
 *
 * Date: Thu May 05 14:23:00 2011 -0600
 */

(function($, sr) {

  "use strict"; // jshint ;_;

  // debouncing function from John Hann
  // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
  var debounce = function(func, threshold, execAsap) {
      var timeout;

      return function debounced() {
        var obj = this,
          args = arguments;

        function delayed() {
          if (!execAsap) func.apply(obj, args);
          timeout = null;
        }

        if (timeout) clearTimeout(timeout);
        else if (execAsap) func.apply(obj, args);

        timeout = setTimeout(delayed, threshold || 100);
      };
    };
    // smartresize
    jQuery.fn[sr] = function(fn) {
      return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr);
    };

})(jQuery, 'smartresize');

(function($) {

  "use strict"; // jshint ;_;

  $.fn.fitText = function(kompressor) {

    return this.each(function() {
      var $this = $(this), // store the object
        fontResize = $this.css('font-size'),
        origFontSize = $this.css('font-size'),
        // init the font sizes
        compressor = kompressor || 1,
        resizer;
      // set the compressor

      // Resizer() resizes items based on the object width divided by the compressor * 10
      resizer = function(obj) {
          fontResize = obj.width() / (compressor * 10);
          fontResize = (fontResize >= origFontSize) ? origFontSize : fontResize;
          obj.css('font-size', fontResize);
      };

      // Call once to set.
      resizer($this);

      // Call on resize. Opera debounces their resize by default.
      $(window).smartresize(function() {
        resizer($this);
      });

    });

  };

})(jQuery);