###
 * Regular expressions to validate any path of the url
 * @type {[type]}
###
REGEXP =
  PROTO: '(http[s]?)'
  DOMAIN: '([A-Za-z0-9-.]{1,63})'
  PORT: '([0-9]{0,4})'
  PATH: '(\/[\/A-Za-z0-9-.]+)'

###
 * Test a test with provided regexp
 * @param  {string} regex
 * @param  {string} str
 * @return {Boolean}
###
test = ( regex, str ) ->
  new RegExp( '^' + regex + '$' ).test( str )

###
 * ResourceUrl
 * Setter/getter of valid urls
 *
 * Example of use:
 *
 * ```coffeescript
 * resourceUrl = new ResourceUrl( 'http://mydomain.com/users/34' )
 * resourceUrl.protocol( 'https' ).port( '8080' )
 *
 * console.log( resourceUrl.url() )
 *
 * # https://mydomain.com:8080/users/34
 *
 * ```
###
class ResourceUrl

  ###
   * @constructor
   * @param  {string} [url] 'http://mydomain.com/users/34'
  ###
  constructor: ( url ) ->
    @url( url ) if !!url

  ###
   * protocol getter/setter
   * @param  {string} value 'http' | 'https'
   * @return {this}
  ###
  protocol: ( value ) ->
    return @_protocol if typeof value is 'undefined'
    throw new Error( 'Invalid protocol.' ) unless test( REGEXP.PROTO, value )
    @_protocol = value
    return this

  ###
   * domain getter/setter
   * @param  {string} value 'mydomain.com'
   * @return {this}
  ###
  domain: ( value ) ->
    return @_domain if typeof value is 'undefined'
    throw new Error( 'Invalid domain.' ) unless test( REGEXP.DOMAIN, value )
    @_domain = value
    return this

  ###
   * port getter/setter
   * @param  {number} value
   * @return {this}
  ###
  port: ( value ) ->
    return @_port if typeof value is 'undefined'
    throw new Error( 'Invalid port.' ) unless test( REGEXP.PORT, value )
    @_port = value
    return this

  ###
   * path getter/setter
   * @param  {string} value '/users/34'
   * @return {this}
  ###
  path: ( value ) ->
    return @_path if typeof value is 'undefined'
    throw new Error( 'Invalid path.' ) unless test( REGEXP.PATH, value )
    @_path = value
    return this

  ###
   * Whole url getter/setter
   * Port will be set to 80 by default, and path to '/'
   * @param  {string} value 'http://mydomain.com/users/34'
   * @return {this}
  ###
  url: ( value ) ->
    if typeof value is 'undefined'
      url = @protocol() + '://' + @domain()
      url += ':' + @port() if @port() isnt 80
      url += @path()

      return url

    regexp = "#{REGEXP.PROTO}://#{REGEXP.DOMAIN}(:#{REGEXP.PORT})?#{REGEXP.PATH}"

    throw new Error( 'Invalid url.' ) unless test( regexp, value )

    # If valid url parts are set
    parts = new RegExp( '^' + regexp + '$' ).exec( value )
    @protocol( parts[1] )
      .domain( parts[2] )
      .port( parts[4] || 80 )
      .path( parts[5] || '/' )

    return this


module.exports = ResourceUrl
