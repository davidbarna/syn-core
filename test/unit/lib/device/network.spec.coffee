describe 'syn-core.device.network', ->

  core = require( 'src/index' )

  changeConnection = (type) ->
    navigator.connection = type: type

  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @instance = core.device.network

  afterEach  ->
    @instance.removeAllListeners(@instance.CHANGE)
    @instance.removeAllListeners(@instance.ONLINE)
    @instance = null
    @sandbox.restore()
    delete navigator.connection

  describe 'init', ->

    it 'should have filled connection constants', ->
      window.Connection.ETHERNET.should.equal 'ETHERNET'

  describe 'events', ->

    beforeEach ->
      @sandbox.stub(@instance, 'emit')

    describe 'when connection changes to online', ->

      beforeEach ->
        changeConnection 'CELL_3G'
        @instance._networkChanged()

      it 'should launch events', ->
        @instance.emit.should.have.been.calledWithExactly(@instance.CHANGE, 'CELL')
        @instance.emit.should.have.been.calledWithExactly(@instance.ONLINE, true)

    describe 'when connection changes to offline', ->

      beforeEach ->
        changeConnection 'UNKNOWN'
        @instance._networkChanged()

      it 'should launch events', ->
        @instance.emit.should.have.been.calledWithExactly(@instance.CHANGE, 'UNKNOWN')
        @instance.emit.should.have.been.calledWithExactly(@instance.ONLINE, false)

    describe 'when connection remains the same', ->

      beforeEach ->
        changeConnection 'CELL_3G'
        @instance._networkChanged()
        @instance.emit.reset()
        @instance._networkChanged()

      it 'should not launch events', ->
        @instance.emit.should.not.have.been.called

  describe 'isOnline', ->

    describe 'when connection status is a network connect', ->

      it 'should return true', ->
        changeConnection 'CELL_3G'
        @instance.isOnline().should.equal true
        changeConnection 'ETHERNET'
        @instance.isOnline().should.equal true
        changeConnection 'WIFI'
        @instance.isOnline().should.equal true

    describe 'when connection status is not network or unknow', ->

      it 'should return false', ->
        changeConnection 'UNKNOWN'
        @instance.isOnline().should.equal false
        changeConnection 'NONE'
        @instance.isOnline().should.equal false

  describe 'getStatus', ->

    it 'should return the connection type', ->
      changeConnection 'ETHERNET'
      @instance.getStatus().should.equal 'ETHERNET'

    describe 'when connection status is a cellphone type', ->

      it 'should return the CELL type', ->
        changeConnection 'CELL_2G'
        @instance.getStatus().should.equal 'CELL'
        changeConnection 'CELL'
        @instance.getStatus().should.equal 'CELL'
        changeConnection 'EDGE'
        @instance.getStatus().should.equal 'CELL'
