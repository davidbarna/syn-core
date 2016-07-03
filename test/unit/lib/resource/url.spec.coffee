describe 'syn-auth.resource.Url', ->

  auth = require( 'src/index.bundle' )

  beforeEach ->
    @instance = new auth.resource.Url()

  afterEach ->

  describe '#contructor', ->

    URL = 'http://video.test.co.uk:80/videoplay'

    beforeEach ->
      @instance = new auth.resource.Url( URL )

    it 'should set url provided', ->
      @instance.url().should.equal URL

  describe '#protocol (get/set)', ->

    beforeEach ->
      @instance.protocol( 'http' )
      @instance.protocol( 'https' )

    it 'should get/set protocol', ->
      @instance.protocol().should.equal 'https'

    describe 'when protocol is invalid', ->

      it 'should throw an error', ->
        ( => @instance.protocol( 'ftp' ) ).should.throw( 'protocol' )
        ( => @instance.protocol( 'http2' ) ).should.throw(  'protocol' )

  describe '#domain (get/set)', ->

    beforeEach ->
      @instance.domain( 'api.mydomain.com' )

    it 'should get/set domain name', ->
      @instance.domain().should.equal 'api.mydomain.com'

    describe 'when domain is invalid', ->

      it 'should throw an error', ->
        ( => @instance.domain( 'domain:com' ) ).should.throw( 'domain' )

  describe '#port (get/set)', ->

    beforeEach ->
      @instance.port( 8080 )

    it 'should get/set port', ->
      @instance.port().should.equal 8080

    describe 'when port is invalid', ->

      it 'should throw an error', ->
        ( => @instance.port( 'post' ) ).should.throw( 'port' )

  describe '#path (get/set)', ->

    beforeEach ->
      @instance.path( '/root/resource' )

    it 'should get/set path', ->
      @instance.path().should.equal '/root/resource'

    describe 'when path is invalid', ->

      it 'should throw an error', ->
        ( => @instance.path( 'root' ) ).should.throw( 'path' )
        ( => @instance.path( 'root/resource' ) ).should.throw( 'path' )

  describe '#url (get/set)', ->

    it 'should get/set url', ->
      url = 'http://video.test.co.uk:8080/videoplay/user'
      @instance.url( url )
      @instance.url().should.equal url

    describe 'when port is not in url', ->

      beforeEach ->
        @instance.url( 'http://video.test.co.uk/videoplay' )

      it 'should set default port to 80', ->
        @instance.port().should.equal 80

      it 'should return url without default port', ->
        @instance.url()
          .should.equal 'http://video.test.co.uk/videoplay'

    describe 'when url is invalid', ->

      it 'should throw an error', ->
        ( => @instance.url( 'http://video.test.com' ) ).should.throw( 'url' )
