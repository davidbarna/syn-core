EventEmitter = require( 'events' ).EventEmitter
win = window

# Service constants
TYPES =
  ETHERNET: 'ETHERNET'
  WIFI: 'WIFI'
  CELL_2G: 'CELL_2G'
  CELL_3G: 'CELL_3G'
  CELL_4G: 'CELL_4G'
  CELL: 'CELL'
  EDGE: 'EDGE'
  UNKNOWN: 'UNKNOWN'
  NONE: 'NONE'

TIME_TO_CHECK_NETWORK = 3000 # each 3 secs

# Get Cordova's global Connection object or emulate a smilar one
if not win.hasOwnProperty('Connection') or Object.keys(win.Connection).length is 0
  win.Connection = TYPES

{ ETHERNET, WIFI, CELL_2G, CELL_3G, CELL_4G, CELL, EDGE, UNKNOWN, NONE } = win.Connection

# Las registered connection, to react only on changes
lastConnectionStatus = null

# Return connection with fallback
getNetworkConnection = ->
  return navigator.connection if !!navigator.connection
  if navigator.onLine
    type: ETHERNET
  else
    type: UNKNOWN

###
 * Service to check the status of device's network connection
###
class DeviceNetwork extends EventEmitter

  CHANGE: 'device:change'
  ONLINE: 'device:online'

  constructor: ->
    this._networkChangedHandler = @_networkChanged.bind(this)
    win.addEventListener 'online', this._networkChangedHandler, false
    win.addEventListener 'offline', this._networkChangedHandler, false
    win.addEventListener 'resume', this._networkChangedHandler, false

    # Pulling all time to know if we have network
    win.setInterval this._networkChangedHandler, TIME_TO_CHECK_NETWORK

    @_networkChanged()

  ###
   * Check if connection has changed and dispatch corresponding events
  ###
  _networkChanged: ->
    status = @getStatus()
    if status isnt lastConnectionStatus
      @emit( @CHANGE, status )
      @emit( @ONLINE, @isOnline() )
      lastConnectionStatus = status
    return

  ###
   * Get wether device is online
   * @return {Boolean} [description]
  ###
  isOnline: ->
    blnReturn = false
    switch @getStatus()
      when ETHERNET, WIFI, CELL
        blnReturn = true
    blnReturn

  ###
   * Get conection type of the device
   * @return {String}
  ###
  getStatus: ->
    status = getNetworkConnection().type
    switch status
      when CELL_2G, CELL_3G, CELL_4G, EDGE
        status = CELL
    return status



module.exports = new DeviceNetwork()
