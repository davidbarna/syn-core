describe 'syn-core.resource.Client', ->

  core = require( 'src/index.bundle' )

  Resource = core.resource.Client
  URL = 'https://test.domain.com:3333/auth'

  beforeEach ->
    @sinon = sinon.sandbox.create()
    @sinon.useFakeServer()
    @instance = new Resource( URL )

  afterEach ->
    @sinon.restore()

  describe '#constructor', ->

    it 'should set resource.Url instance', ->
      @instance._url.url().should.equal URL

  describe '#request', ->

    describe 'when response is OK with json content', ->

      beforeEach ->
        @sinon.server.respondWith( 'GET', URL, [
          200,
          { 'Content-Type': 'application/json' },
          '{ "name": "John", "surname": "Smith" }'
        ] )

      it 'should resolve promise with parsed response', ( done ) ->
        @instance.request( 'GET' )
          .then ( response ) ->
            response.surname.should.equal 'Smith'
            done()
            return response
        @sinon.server.respond()

    describe 'when response is OK with invalid json content', ->

      beforeEach ->
        @sinon.server.respondWith( 'GET', URL, [
          200,
          { 'Content-Type': 'application/json' },
          'Error Message'
        ] )

      it 'should throw a syntax error', ( done ) ->
        @instance.request( 'GET' )
          .catch ( error ) ->
            error.message.should.contain 'Unexpected'
            done()
            return error
        @sinon.server.respond()

    describe 'when response is KO', ->

      beforeEach ->
        @sinon.server.respondWith( 'GET', URL, [
          404,
          { 'Content-Type': 'application/json' },
          '{ "status": 404, "message": "Not Found" }'
        ] )

      it 'should throw http error', ( done ) ->
        @instance.request( 'GET' )
          .catch ( error ) ->
            error.message.should.contain '404'
            done()
            return error

        setTimeout done, 500
        @sinon.server.respond()

    describe 'when response times out', ->

      beforeEach ->
        Resource.setTimeout( 100 )
        @sinon.restore()

      afterEach ->
        Resource.setTimeout( Resource.DEFAULT_TIMEOUT )

      it 'should throw timeout error', ( done ) ->
        @instance.request( 'GET' )
          .catch ( error ) ->
            error.message.should.contain 'timeout'
            done()
