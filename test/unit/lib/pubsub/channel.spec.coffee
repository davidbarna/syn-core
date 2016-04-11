describe 'syn-core.pubsub.Channel', ->

  core = require( 'src/' )
  Channel = core.pubsub.Channel

  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @instance = new Channel 'fakeChannelName'

  afterEach  ->
    @instance = null
    @sandbox.restore()

  describe '#constructor', ->

    it 'should init props', ->
      @instance.name.should.equal 'fakeChannelName'
      @instance.events.length.should.equal 0

    it 'should register events keys', ->
      _events = ['event1', 'event2', 'event3', 'event4']
      registerEvents = @sandbox.stub Channel.prototype, 'registerEvents'
      instance = new Channel 'fake', _events

      registerEvents.should.have.been.calledOnce
      registerEvents.should.have.been.calledWith _events

  describe '#registerEvent', ->

    beforeEach ->
      @instance.registerEvent 'fake-event-1'

    it 'should register pubsub event in the instance instance', ->
      @instance['fake-event-1'].should.exist
      @instance['fake-event-1'].publish.should.be.a 'function'
      @instance['fake-event-1'].subscribe.should.be.a 'function'
      @instance['fake-event-1'].unsubscribe.should.be.a 'function'

    it 'should not register event if exists', ->
      @instance['fake-event-2'] = 'fake-value'
      @instance.registerEvent 'fake-event-2'
      @instance['fake-event-2'].should.equal 'fake-value'

  describe '#registerEvents', ->

    it 'should register each event key', ->
      registerEvent = @sandbox.stub @instance, 'registerEvent'
      @instance.registerEvents ['fake-event-1', 'fake-event-2', 'fake-event-3']

      registerEvent.should.have.been.called
      registerEvent.callCount.should.equal 3
      registerEvent.should.have.been.calledWithExactly 'fake-event-3'

  describe '#unregisterAllEvents', ->

    it 'should un register all events', ->
      @instance.registerEvent 'event1'
      @instance.registerEvent 'event2'
      @instance.unregisterAllEvents()

      @instance.hasOwnProperty('event1').should.be.false
      @instance.hasOwnProperty('event2').should.be.false
      @instance.events.length.should.equal 0
