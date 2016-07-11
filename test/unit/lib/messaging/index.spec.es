import Messaging from 'src/lib/messaging'
import MesssagingUiInterface from 'src/lib/messaging/ui/interface'
import MesssagingUIConsole from 'src/lib/messaging/ui/console'

describe('lib/messaging', function () {
  var sandbox, messaging

  beforeEach(function () {
    sandbox = sinon.sandbox.create()
    sandbox.spy(Messaging.prototype, 'setUIService')
    messaging = new Messaging()
  })

  afterEach(function () {
    sandbox.restore()
  })

  describe('#constructor', function () {
    it('should set default service', function () {
      messaging.setUIService.should.have.been.called
      messaging.setUIService.args[0][0].should.be.instanceOf(MesssagingUiInterface)
    })
  })

  describe('#setUIService', function () {
    describe('when given service does not implement interface', function () {
      it('should throw an error', function () {
        (function () { messaging.setUIService({}) }).should.throw
      })
    })

    describe('when given service does implement interface', function () {
      it('should expose the service as ui property', function () {
        let service = new MesssagingUIConsole()
        messaging.setUIService(service)
        messaging.ui.confirm.should.equal(service.confirm)
      })
    })
  })
})
