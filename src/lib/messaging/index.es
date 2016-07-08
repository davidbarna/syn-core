import MesssagingUIConsole from './ui/console'
import MesssagingUiInterface from './ui/interface'

var instance = null

/**
 * Global messaging services handlers.
 * For now, only ui messaging service are implemented but in
 * a future, logging, analytics services can be defined.
 */
class Messaging {

  constructor () {
    this.setUIService(new MesssagingUIConsole())
  }

  /**
   * Sets the service to be used for UI messages
   * @param {MesssagingUiInterface} service
   */
  setUIService (service) {
    let isInstance = service instanceof MesssagingUiInterface
    if (!isInstance) {
      throw new Error('Messaging: invalid ui service.')
    }
    this.ui = service
  }

  /**
   * Returns Singleton instance of the class
   * @return {Messaging}
   */
  static getInstance () {
    if (!instance) {
      instance = new Messaging()
    }
    return instance
  }

}

export default Messaging
