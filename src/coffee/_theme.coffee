###
 # Theme
###

(($) ->
  $window = $(window)
  $document = $(document)
  
  #
  # * Scrollspy.
  # 
  $document.on "flatdoc:ready", ->
    $("h2, h3").scrollagent (cid, pid, currentElement, previousElement) ->
      $("[href='#" + pid + "']").removeClass "active"  if pid
      $("[href='#" + cid + "']").addClass "active"  if cid


  
  #
  # * Anchor jump links.
  # 
  $document.on "flatdoc:ready", ->
    $(".menu a").anchorjump()

  
  #
  # * Title card.
  # 
  $ ->
    $card = $(".title-card")
    return  unless $card.length
    $header = $(".header")
    headerHeight = (if $header.length then $header.outerHeight() else 0)
    $window.on("resize.title-card", ->
      windowWidth = $window.width()
      if windowWidth < 480
        $card.css "height", ""
      else
        height = $window.height()
        $card.css "height", height - headerHeight
    ).trigger "resize.title-card"
    $card.fillsize "> img.bg"

  
  #
  #  * Sidebar stick.
  #  
  $ ->
    $sidebar = $(".menubar")
    elTop = undefined
    $window.on("resize.sidestick", ->
      elTop = $sidebar.offset().top
      $window.trigger "scroll.sidestick"
    ).on("scroll.sidestick", ->
      scrollY = $window.scrollTop()
      $sidebar.toggleClass "fixed", (scrollY >= elTop)
    ).trigger "resize.sidestick"

) jQuery

#! jQuery.scrollagent (c) 2012, Rico Sta. Cruz. MIT License.
# *  https://github.com/rstacruz/jquery-stuff/tree/master/scrollagent 

# Call $(...).scrollagent() with a callback function.
#
# The callback will be called everytime the focus changes.
#
# Example:
#
#      $("h2").scrollagent(function(cid, pid, currentElement, previousElement) {
#        if (pid) {
#          $("[href='#"+pid+"']").removeClass('active');
#        }
#        if (cid) {
#          $("[href='#"+cid+"']").addClass('active');
#        }
#      });
(($) ->
  $.fn.scrollagent = (options, callback) ->
    
    # Account for $.scrollspy(function)
    if typeof callback is "undefined"
      callback = options
      options = {}
    $sections = $(this)
    $parent = options.parent or $(window)
    
    # Find the top offsets of each section
    offsets = []
    $sections.each (i) ->
      offset = (if $(this).attr("data-anchor-offset") then parseInt($(this).attr("data-anchor-offset"), 10) else (options.offset or 0))
      offsets.push
        top: $(this).offset().top + offset
        id: $(this).attr("id")
        index: i
        el: this


    
    # State
    current = null
    height = null
    range = null
    
    # Save the height. Do this only whenever the window is resized so we don't
    # recalculate often.
    $(window).on "resize", ->
      height = $parent.height()
      range = $(document).height()

    
    # Find the current active section every scroll tick.
    $parent.on "scroll", ->
      y = $parent.scrollTop()
      y += height * (0.3 + 0.7 * Math.pow(y / range, 2))
      latest = null
      for i of offsets
        if offsets.hasOwnProperty(i)
          offset = offsets[i]
          latest = offset  if offset.top < y
      if latest and (not current or (latest.index isnt current.index))
        callback.call $sections, (if latest then latest.id else null), (if current then current.id else null), (if latest then latest.el else null), (if current then current.el else null)
        current = latest

    $(window).trigger "resize"
    $parent.trigger "scroll"
    this
) jQuery

#! Anchorjump (c) 2012, Rico Sta. Cruz. MIT License.
# *   http://github.com/rstacruz/jquery-stuff/tree/master/anchorjump 

# Makes anchor jumps happen with smooth scrolling.
#
#    $("#menu a").anchorjump();
#    $("#menu a").anchorjump({ offset: -30 });
#
#    // Via delegate:
#    $("#menu").anchorjump({ for: 'a', offset: -30 });
#
# You may specify a parent. This makes it scroll down to the parent.
# Great for tabbed views.
#
#     $('#menu a').anchorjump({ parent: '.anchor' });
#
# You can jump to a given area.
#
#     $.anchorjump('#bank-deposit', options);
(($) ->
  defaults =
    speed: 500
    offset: 0
    for: null
    parent: null

  $.fn.anchorjump = (options) ->
    onClick = (e) ->
      $a = $(e.target).closest("a")
      return  if e.ctrlKey or e.metaKey or e.altKey or $a.attr("target")
      e.preventDefault()
      href = $a.attr("href")
      $.anchorjump href, options
    options = $.extend({}, defaults, options)
    if options["for"]
      @on "click", options["for"], onClick
    else
      @on "click", onClick

  
  # Jump to a given area.
  $.anchorjump = (href, options) ->
    options = $.extend({}, defaults, options)
    top = 0
    unless href is "#"
      $area = $(href)
      
      # Find the parent
      if options.parent
        $parent = $area.closest(options.parent)
        $area = $parent  if $parent.length
      return  unless $area.length
      
      # Determine the pixel offset; use the default if not available
      offset = (if $area.attr("data-anchor-offset") then parseInt($area.attr("data-anchor-offset"), 10) else options.offset)
      top = Math.max(0, $area.offset().top + offset)
    $("html, body").animate
      scrollTop: top
    , options.speed
    $("body").trigger "anchor", href
    
    # Add the location hash via pushState.
    if window.history.pushState
      window.history.pushState
        href: href
      , "", href
) jQuery

#! fillsize (c) 2012, Rico Sta. Cruz. MIT License.
# *  http://github.com/rstacruz/jquery-stuff/tree/master/fillsize 

# Makes an element fill up its container.
#
#     $(".container").fillsize("> img");
#
# This binds a listener on window resizing to automatically scale down the
# child (`> img` in this example) just so that enough of it will be visible in
# the viewport of the container.
# 
# This assumes that the container has `position: relative` (or any 'position',
# really), and `overflow: hidden`.
(($) ->
  $.fn.fillsize = (selector) ->
    resize = ->
      $img = $parent.find(selector)  unless $img
      $img.each ->
        return  unless @complete
        $img = $(this)
        parent =
          height: $parent.innerHeight()
          width: $parent.innerWidth()

        imageRatio = $img.width() / $img.height()
        containerRatio = parent.width / parent.height
        css =
          position: "absolute"
          left: 0
          top: 0
          right: "auto"
          bottom: "auto"

        
        # If image is wider than the container
        if imageRatio > containerRatio
          css.left = Math.round((parent.width - imageRatio * parent.height) / 2) + "px"
          css.width = "auto"
          css.height = "100%"
        
        # If the container is wider than the image
        else
          css.top = Math.round((parent.height - (parent.width / $img.width() * $img.height())) / 2) + "px"
          css.height = "auto"
          css.width = "100%"
        $img.css css

    $parent = this
    $img = undefined
    
    # Make it happen on window resize.
    $(window).resize resize
    
    # Allow manual invocation by doing `.trigger('fillsize')` on the container.
    $(document).on "fillsize", $parent.selector, resize
    
    # Resize on first load (or immediately if called after).
    $ ->
      
      # If the child is an image, fill it up when image's real dimensions are
      # first determined. Needs to be .bind() because the load event will
      # bubble up.
      $(selector, $parent).bind "load", ->
        setTimeout resize, 25

      resize()

    this
) jQuery