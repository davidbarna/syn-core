###
 * ResourceClient
 *
 * Sends http requests and returns promise resolved by the response.
 *
 * If status code of the response is not a success code, then the promise
 * is rejected with an Error with status property.
 *
 * If response timesout, promise is rejected as well.
 *
 * ```coffeescript
 * client = new ResourceClient( 'http://mydomain.com/users' )
 * client.get( headers: [ token: 'myAuthToken' ] )
 *   .then ( users ) ->
 *    console.log( users )
 * ```
###
class ResourceClient

  ResourceUrl = require( './url' )
  TokenRefresher = require( './interceptor/refresh' )

  ###
   * Default timeout for all requests if undefined
   * @type {number}
  ###
  DEFAULT_TIMEOUT: 5000

  ###
   * @constructor
   * @param  {string} url Resource url
  ###
  constructor: ( url ) ->
    @_url = new ResourceUrl( url )

    ResourceClient.interceptor ?=
      new window.syn.core.resource.InterceptorManager()

  ###
   * Sets url of server's service
   * @param {string} url Must be absolute url
   * @return {this}
  ###
  setUrl: ( url ) ->
    @_url.url( url )
    return this

  ###
   * Sends a http request and returns a promise resolved by its response
   * @param  {string} method
   * @param  {object} [opts] Send options like 'headers'
   * @return {Promise}
  ###
  request: ( method, opts ) ->
    getHttpRequestFromUrl( method, @_url.url(), opts )

  ###
   * Shortcut for @request( 'GET', [opts] )
   * @param  {Object} opts
   * @return {Promise}
  ###
  get: ( opts ) ->
    @request( 'GET', opts )

  ###
   * Shortcut for @request( 'POST', [opts] )
   * @param  {Object} opts
   * @return {Promise}
  ###
  post: ( opts ) ->
    @request( 'POST', opts )

  enableInterceptors: ->
    TokenRefresher.enable()
    return this



###
 * Request interceptor
 * @type {?Object}
###
ResourceClient.interceptor = null

###
 * Sets timeout for all resquests
 * @param {number} ms Time in milliseconds
###
ResourceClient.setTimeout = ( ms ) ->
  @timeout = ms || @DEFAULT_TIMEOUT

###
 * Creates a XMLHttpRequest converted to a Promise
 *
 * If status code of the response is not a success code, then the promise
 * is rejected with an Error with status property.
 *
 * If response timesout, promise is rejected as well.
 *
 * @param  {string} method
 * @param  {string} url
 * @param  {Object} [opts] Send options like 'headers'
 * @return {Promise}
###
getHttpRequestFromUrl = ( method, url, opts = {} ) ->
  Promise = require( 'bluebird' )

  new Promise ( resolve, reject ) ->
    xhr = new XMLHttpRequest( opts )
    xhr.timeout = ResourceClient.timeout || ResourceClient.DEFAULT_TIMEOUT

    xhr.addEventListener( 'error', ( evt ) ->
      reject( getHttpError( evt.target ) )
    )
    xhr.addEventListener( 'timeout', ( evt ) ->
      reject( getTimeoutError( evt.target ) )
    )
    xhr.addEventListener( 'load', ( response ) ->
      ResourceClient.interceptor.process( 'response', response )
      .then ( processedResponse ) ->
        processResponse( processedResponse.target, resolve, reject )
    )
    xhr.open( method, url, true )

    for headerName, headerValue of opts.headers
      xhr.setRequestHeader( headerName, headerValue )

    xhr.send( null )

###
 * Handles problems of a successfull response
 * that should be considered as errors: json parsing error and
 * non successfull htp status code
 *
 * @param  {XMLHttpRequest} req Http request
 * @param  {Function} resolve
 * @param  {Function} reject
 * @return {undefined}
###
processResponse = ( req, resolve, reject ) ->
  if isValidRequest( req )
    try
      resolve( JSON.parse( req.response ) )
    catch e
      reject( getParseError( e ) )
  else
    reject( getHttpError( req ) )
  return

###
 * Returns if an http status code is considered a success
 * @param  {XMLHttpRequest}  req Http request
 * @return {Boolean}
###
isValidRequest = ( req ) ->
  300 > req.status >= 200

###
 * Returns an error base on http "falsy" status code
 * @param  {XMLHttpRequest} req Http request
 * @return {Error}
###
getHttpError = ( req ) ->
  error = new Error( 'HTTP ' + req.status )
  error.status = req.status
  return error

###
 * Returns timeout error
 * @param  {XMLHttpRequest} req Http request
 * @return {Error}
###
getTimeoutError = ( req ) ->
  new Error( 'Request timeout (' + req.timeout + 'ms)' )

###
 * Converts Parse error object to regular error
 * @param  {ParseError} error
 * @return {Error}
###
getParseError = ( error ) ->
  err = new Error( error.message )
  err.stack = error.stack
  return err



module.exports = ResourceClient