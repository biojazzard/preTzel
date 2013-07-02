###
 * @namespace APPBIO
 *
 * @author Alfredo Llanos <alfredo@tallerdelsoho.es> || @biojazzard
###

APPBIO.Script = ((appbio, $, µ, undefined_) ->

  s = null
  position = null
  config =
    settings:
      pretzel: true
      version: 'static'

  #global vars
  init = () ->

    ###
     # init
    ###

    #_log '@Script.init'

    s = config.settings
    _log s.version

   _log = (m) ->
    console.log m

  init: init

)(APPBIO, jQuery, Modernizr)
