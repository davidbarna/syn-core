describe 'syn-core.pubsub.channel.factory', ->

  core = require( 'src/index')
  factory = core.pubsub.channel.factory
  Channel = core.pubsub.Channel
  ROOT_CHANNELS_NS = '__synCore__PubSubChannelFactory__Channels'

  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach  ->
    @sandbox.restore()
    @instance = null

  describe '#constructor', ->

    beforeEach ->
      @instance = factory.create 'fakeChannel', ['event1', 'event2']

    afterEach ->
      @instance.destroy()

    it 'should add channels to global scope', ->
      window[ROOT_CHANNELS_NS].should.equal(factory.channels)

    it 'should create instance with given events keys', ->
      @instance['event1'].publish.should.be.a 'function'
      @instance['event1'].subscribe.should.be.a 'function'
      @instance['event1'].unsubscribe.should.be.a 'function'
      @instance['event2'].publish.should.be.a 'function'

    it 'should add events if channel already exists', ->
      channelConstructor = @sandbox.stub Channel.prototype, 'constructor'
      instance = factory.create 'fakeChannel', ['event2', 'event3']

      channelConstructor.should.not.have.been.called

      @instance['event1'].publish.should.be.a 'function'
      @instance['event2'].publish.should.be.a 'function'
      @instance['event3'].publish.should.be.a 'function'

      instance.destroy()

    it 'should subscribe to destroy to control destruction', ->
      destroy = @sandbox.spy factory, 'destroy'
      @instance.destroy()
      destroy.should.have.been.calledOnce
      destroy.should.have.been.calledWith 'fakeChannel'

  describe '#destroy', ->

    beforeEach ->
      @instance = factory.create 'fakeChannel', ['event1', 'event2']
      @instance = factory.create 'fakeChannel', ['event1', 'event3']
      @instance = factory.create 'fakeChannel', ['event3', 'event6']

      @unregisterAllEvents = @sandbox.stub @instance, 'unregisterAllEvents'

    afterEach ->
      @instance.destroy()
      @instance.destroy()
      @instance.destroy()

    it 'should not destroy channel if channels count is not 1',  ->
      @instance.destroy()
      @instance.destroy()

      @instance.event2.publish.should.exist
      @unregisterAllEvents.should.not.have.been.called

    it 'should not destroy channel if channels count is 1',  ->
      @instance.destroy()
      @instance.destroy()
      @instance.destroy()
      @unregisterAllEvents.should.have.been.called

      instance = factory.create 'fakeChannel', ['event99']
      instance.hasOwnProperty('event2').should.be.false
      instance.hasOwnProperty('event99').should.be.true
