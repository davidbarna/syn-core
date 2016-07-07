describe 'interceptor.handler', ->
  core = require( 'src/index')
  pubsub = require( 'src/lib/pubsub/channel-factory' )
  InterceptorHandler = require( 'src/lib/resource/interceptor/handler' )
    .InterceptorHandler

  ADD_CHANNEL = 'interceptors:add'
  METHOD = 'add'
  FAKE_ERROR = 'fakeError'

  beforeEach ->
    @sandbox = sinon.sandbox.create()

    ###
     * Loads three default interceptors into a given
     * InterceptorHandler
     * @param {InterceptorHandler}
    ###
    @loadInterceptors = ( instance ) ->
      @resolvingResponse = @sandbox.spy()
      @resolvingResponseIntercetor = {
        'response': ( data, resolve, reject, options ) =>
          @resolvingResponse( data, resolve, reject, options )
          resolve({})
          return true
      }
      @rejectingResponse = @sandbox.spy()
      @rejectingResponseInterceptor = {
        'response': ( data, resolve, reject, options ) =>
          @rejectingResponse( data, resolve, reject, options )
          reject( new Error( FAKE_ERROR ) )
          return false
      }
      @resolvingRequest = @sandbox.spy()
      @resolvingRequestInterceptor = {
        'request': ( data, resolve, reject, options ) =>
          @resolvingRequest( data, resolve, reject, options )
          resolve()
          return true
      }
      instance._interceptors.push( @resolvingResponseIntercetor )
      instance._interceptors.push( @rejectingResponseInterceptor )
      instance._interceptors.push( @resolvingRequestInterceptor )

  afterEach ->
    @sandbox.restore()

  describe '#constructor', ->
    beforeEach ->
      @instance = new InterceptorHandler()

    it 'should initialize the interceptors array', ->
      expect( @instance._interceptors.length ).to.be.equal( 0 )

    describe 'when the add event is published', ->
      beforeEach ->
        @fakeInterceptor = {
          'response': ->
        }
        event = pubsub.create( ADD_CHANNEL, [METHOD] )
        event[METHOD].publish( @fakeInterceptor )

      it 'should add an interceptor', ->
        expect( @instance._interceptors.length ).to.be.equal( 1 )
        expect( @instance._interceptors[0] ).to.deep.equal( @fakeInterceptor )

  describe '#add', ->
    beforeEach ->
      @instance = new InterceptorHandler()

    describe 'when wrong interceptor object is passed as parameter', ->
      beforeEach ->
        @sandbox.stub( console, 'error' )
        @instance.add( 'wrongParam' )

      it 'should log a warning', ->
        console.error.should.have.been.calledOnce

      it 'should not add it as one of the interceptors', ->
        expect( @instance._interceptors.length ).to.be.equal( 0 )

    describe 'when wrong interceptor callback is passed', ->
      beforeEach ->
        @sandbox.stub( console, 'error' )
        @instance.add( { 'response': 'noFunction' } )

      it 'should log an error', ->
        console.error.should.have.been.calledOnce

      it 'should not add it as one of the interceptors', ->
        expect( @instance._interceptors.length ).to.be.equal( 0 )

    describe 'when an object is passed as parameter', ->
      beforeEach ->
        @sandbox.stub( console, 'warn' )
        @sandbox.stub( console, 'error' )
        @instance.add( { 'response': -> } )

      it 'should insert the interceptor', ->
        expect( @instance._interceptors.length ).to.be.equal( 1 )

      it 'should not show any error', ->
        console.warn.should.not.have.been.called
        console.error.should.not.have.been.called

  describe '#remove', ->
    beforeEach ->
      @instance = new InterceptorHandler()
      @loadInterceptors( @instance )

      @instance.remove( @resolvingResponseIntercetor )

    it 'should remove the right interceptor', ->
      @instance._interceptors.length.should.be.equal( 2 )
      @instance._interceptors[0].should.deep.equal( @rejectingResponseInterceptor )
      @instance._interceptors[1].should.deep.equal( @resolvingRequestInterceptor )

  describe '#process', ->
    describe 'when no interceptor is rejected', ->
      beforeEach ->
        @instance = new InterceptorHandler()
        @fakeData = { status: 200 }
        @fakeOptions = { auth: 'fake' }
        @loadInterceptors( @instance )

        @promise = @instance.process( 'request', @fakeData, @fakeOptions )

      afterEach ->
        @instance = null

      it 'should call the right interceptor', ( done ) ->
        @promise.then =>
          @resolvingResponse.should.not.be.called
          @rejectingResponse.should.not.be.called
          @resolvingRequest.should.have.been.calledOnce
          done()
          return true
        .catch ( e ) -> console.log( e.message )

      it 'should call the interceptor with the right parameters', ( done ) ->
        @promise.then =>
          args = @resolvingRequest.args[0]
          args[0].should.be.deep.equal( @fakeData )
          expect( typeof args[1] ).to.be.equal( 'function' )
          expect( typeof args[2] ).to.be.equal( 'function' )
          args[3].should.be.deep.equal( @fakeOptions )
          done()
          return true
        .catch ( e ) -> console.log( e.message )

    describe 'when one of the interceptors called reject', ->
      beforeEach ->
        @instance = new InterceptorHandler()
        @fakeData = { status: 200 }
        @fakeOptions = { auth: 'fake' }
        @loadInterceptors( @instance )

        @promise = @instance.process( 'response', @fakeData, @fakeOptions )

      afterEach ->
        @instance = null

      it 'should throw an error', ( done ) ->
        @promise.then ->
          return true
        .catch ( e ) =>
          expect( e.message ).to.be.equal( FAKE_ERROR )
          @resolvingResponse.should.have.been.calledOnce
          @rejectingResponse.should.have.been.calledOnce
          @resolvingRequest.should.not.been.called
          done()
          return true
