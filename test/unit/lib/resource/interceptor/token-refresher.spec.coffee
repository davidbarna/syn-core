describe 'interceptor.refresh.enable', ->
  enableTokenRefresher = require( 'src/lib/resource/interceptor/token-refresher' )
    .enable
  TokenRefresher = require( 'src/lib/resource/interceptor/token-refresher' )
    .TokenRefresher
  pubsub = require( 'src/lib/pubsub/channel-factory' )

  ADD_CHANNEL = 'interceptors:add'
  METHOD = 'add'

  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @sandbox.stub( TokenRefresher::, 'enable' )
    @subscribeSpy = @sandbox.spy()
    event = pubsub.create( ADD_CHANNEL, [METHOD] )
    event[METHOD].subscribe( ( interceptor ) =>
      @subscribeSpy( interceptor )
    )

    mandatoryTokenRefresherOptions =
      refreshRequestFn: ->

    enableTokenRefresher( mandatoryTokenRefresherOptions )

  afterEach ->
    TokenRefresher::destroy()
    @sandbox.restore()

  it 'should publish the interceptor add event', ->
    @subscribeSpy.should.have.been.calledOnce
    expect( Object.keys( @subscribeSpy.args[0][0] )[0] ).to.be.equal( 'response' )

  it 'should enable the token refresher', ->
    TokenRefresher::enable.should.have.been.calleOnce

describe 'interceptor.refresh.TokenRefresher', ->
  TokenRefresher = require( 'src/lib/resource/interceptor/token-refresher' )
    .TokenRefresher
  pubsub = require( 'src/lib/pubsub/channel-factory' )
  core = require( 'src/index.bundle' )
  Promise = require( 'bluebird' )

  window.syn ?= {}
  window.syn.auth ?= {}
  window.syn.auth.session ?= {}
  window.syn.auth.session.global ?= {}

  beforeEach ->
    @sandbox = sinon.sandbox.create()

    @fakeRefreshResponse =
      token:
        access_token: 'fakeAccessToken'
        expires_in: 1
        refresh_token: 'fakeRefreshToken'

    @loadAuthSessionStub = ( stayLoggedIn = true ) ->
      @session =
        stayLoggedIn: @sandbox.stub().returns( stayLoggedIn )
        token: @sandbox.spy()
        expiresIn: @sandbox.spy()
        refreshToken: @sandbox.spy()

      @gSession =
        clear: @sandbox.spy()
        get: => return @session
        set: @sandbox.spy()

      window.syn.auth.session.global = @gSession
      return

    @fakeOptions =
      refreshRequestFn: @sandbox.stub().returns( new Promise ( resolve ) =>
        resolve( @fakeRefreshResponse )
        return true
      )

  afterEach ->
    @sandbox.restore()

  describe '#constructor', ->
    describe 'when no refresh request is passed as parameter', ->
      beforeEach ->
        @sandbox.stub( console, 'error' )
        @instance = new TokenRefresher( {} )

      afterEach ->
        @instance.destroy()

      it 'should log an error', ->
        console.error.should.be.calledOnce

  describe '#updateToken', ->
    describe 'when no token is passed as parameter', ->
      beforeEach ->
        @loadAuthSessionStub()
        @instance = new TokenRefresher( @fakeOptions )
        try
          @instance.updateToken()
        catch error
          @error = error

      afterEach ->
        @instance.destroy()

    describe 'when the token is passed as parameter', ->
      beforeEach ->
        @loadAuthSessionStub()
        @instance = new TokenRefresher( @fakeOptions )
        @instance.updateToken( @fakeRefreshResponse )

      afterEach ->
        @instance.destroy()

      it 'should update session token', ->
        @session.token.should.have.been.calledOnce
        @session.token.should.have.been.calledWith( 'fakeAccessToken' )

      it 'should update session expiresIn', ->
        @session.expiresIn.should.have.been.calledOnce
        @session.expiresIn.should.have.been.calledWith( 1 )

      it 'should update session refreshToken', ->
        @session.refreshToken.should.have.been.calledOnce
        @session.refreshToken.should.have.been.calledWith( 'fakeRefreshToken' )

      it 'should update the local storage saved session', ->
        @gSession.set.should.have.been.calledOnce

  describe '#retry', ->
    describe 'when no retry callback is set', ->
      beforeEach ->
        @instance = new TokenRefresher( @fakeOptions )
        @retryResult = @instance.retry()

      afterEach ->
        @instance.destroy()

      it 'should do nothing', ->
        expect( @retryResult ).to.be.equal( undefined )

    describe 'when retry callback is set', ->
      beforeEach ->
        @retryRequestFn = @sandbox.spy()
        @fakeOptions.retryRequestFn = @retryRequestFn
        @instance = new TokenRefresher( @fakeOptions )
        @instance.retry( { url: 'fakeUrl', options: { method: 'fakeMethod' } } )

      it 'should call the request retry callback', ->
        @retryRequestFn.should.have.been.calledOnce
        @retryRequestFn.should.have.been.calledWithExactly(
          'fakeUrl', { method: 'fakeMethod', rawResult: true }
        )

  describe '#interceptor', ->
    beforeEach ->
      @resolve = @sandbox.spy()
      @reject = @sandbox.spy()
      @fakeOpts = { method: 'fakeMethod' }

    describe 'when the status does not match with the one to be intercepted', ->
      beforeEach ->
        @fakeReq = { status: 200 }
        @instance = new TokenRefresher( @fakeOptions )
        @instance.interceptor( @fakeReq, @resolve, @reject, @fakeOpts )

      afterEach ->
        @instance.destroy()

      it 'should not intercept the request', ->
        @resolve.should.be.calledOnce
        @resolve.should.be.calledWithExactly( @fakeReq )

    describe 'when the status does match with the one to be intercepted', ->
      beforeEach ->
        @loadAuthSessionStub()
        @fakeRetryData = {
          url: 'fakeUrl'
          options: {}
        }
        @fakeReq = { status: 419 }
        @fakeRetryResult = { status: 200 }
        @fakeOptions.retryRequestFn = @sandbox.stub().returns( new Promise ( resolve ) =>
          resolve( @fakeRetryResult )
          return true
        )

        @instance = new TokenRefresher( @fakeOptions )
        @promise = @instance.interceptor( @fakeReq, @resolve, @reject, @fakeRetryData )

      afterEach ->
        @instance.destroy()

      it 'should intercept the request', ( done ) ->
        @promise.then =>
          @resolve.should.been.calledOnce
          done()
          return true
        .catch ( e ) -> console.error( e.message )

  describe '#_onSessionExpired', ->
    beforeEach ->
      @resolve = @sandbox.spy()
      @reject = @sandbox.spy()

    describe 'when max nr of attempts reached', ->
      beforeEach ->
        @loadAuthSessionStub()
        @instance = new TokenRefresher( @fakeOptions )
        @instance.attempts = 100
        @instance._onSessionExpired({}, @resolve, @reject)

      afterEach ->
        @instance.destroy()

      it 'should reject the interceptor', ->
        @reject.should.be.calledOnce
        @reject.should.be.calledWithExactly(
          new Error( 'TokenRefresher: Max. nr. of retries reached' )
        )

      it 'should clear the session', ->
        window.syn.auth.session.global.clear.should.have.been.calledOnce

    describe 'when the user did not check the stay logged in checkbox', ->
      beforeEach ->
        @loadAuthSessionStub( false )
        @instance = new TokenRefresher( @fakeOptions )
        @instance._onSessionExpired({}, @resolve, @reject)

      afterEach ->
        @instance.destroy()

      it 'should reject the interceptor', ->
        @reject.should.be.calledOnce
        @reject.should.be.calledWithExactly(
          new Error( 'TokenRefresher: Session expired' )
        )

      it 'should clear the session', ->
        window.syn.auth.session.global.clear.should.have.been.calledOnce

    describe 'when there is no condition to reject', ->
      beforeEach ->
        @loadAuthSessionStub()
        @fakeRetryData = {
          url: 'fakeUrl'
          options: {}
        }
        @fakeRetryResult = { status: 200 }
        @fakeOptions.retryRequestFn = @sandbox.stub().returns( new Promise ( resolve ) =>
          resolve( @fakeRetryResult )
          return true
        )
        @instance = new TokenRefresher( @fakeOptions )
        @promise = @instance._onSessionExpired({}, @resolve, @reject, @fakeRetryData )

      afterEach ->
        @instance.destroy()

      it 'should call the retry function with the right data', ( done ) ->
        @promise.then =>
          @fakeOptions.retryRequestFn.should.have.been.calledWith(
            @fakeRetryData.url, @fakeRetryData.options
          )
          done()
          return true
        .catch ( e ) -> console.error( e.message )

      it 'should resolve with the retry results', ( done ) ->
        @promise.then =>
          @resolve.should.have.been.calledOnce
          @resolve.should.have.been.calledWithExactly( @fakeRetryResult )
          done()
          return true
        .catch ( e ) -> console.error( e.message )

    describe 'when there is an error retrieving the token', ->
      beforeEach ->
        @loadAuthSessionStub()
        options = refreshRequestFn: @sandbox.stub().returns( new Promise ( resolve ) ->
          resolve( {} )
          return true
        )

        @instance = new TokenRefresher( options )
        @promise = @instance._onSessionExpired({}, @resolve, @reject, @fakeRetryData )

      afterEach ->
        @instance.destroy()

      it 'should reject the interceptor', ( done ) ->
        @promise.then =>
          @reject.should.have.been.calledOnce
          @reject.should.be.calledWithExactly(
            new Error( 'TokenRefresher: Error retrieving the new token' )
          )
          done()
          return true
        .catch ( e ) -> console.error( e.message )

      it 'should clear the session', ( done ) ->
        @promise.then ->
          window.syn.auth.session.global.clear.should.have.been.calledOnce
          done()
          return true
        .catch ( e ) -> console.error( e.message )
