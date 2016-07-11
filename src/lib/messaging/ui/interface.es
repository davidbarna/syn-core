/**
 * Interface for services in charge of displaying messages to user.
 */
class MesssagingUiInterface {

  /**
   * Displays a message with a confirm button
   * @param  {Object} options Messages options
   * @param  {Object} options.title Title of the message
   * @param  {Object} options.text Text of the message
   * @param  {Boolen} options.allowClosure = true Whether to block message closing
   * @return {Promise} Promise resolved on user response {Boolean}
   */
  confirm (options) {
    throw new Error('MesssagingUiInterface: undefined alert()  method')
  }
}

export default MesssagingUiInterface
