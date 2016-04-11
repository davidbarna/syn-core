###
#PubSubChannelFactory

Creates `PubSubChannel` channnels with
predefined basic event:
> **destroy**
> Called when the channel gets destroyed

Each channel as a unique instance.

Example of use:

```coffeescript
# In some component
pubsub = factory.create( 'my-channel', [ 'click' ] )
document.getElementById( 'button', -> pubsub.click.publish() )


# In some controller
pubsub = factory.create( 'my-channel', [ 'click' ] )
pubsub.click.subscribe( ->
  # Do some stuff
)
```

###
class PubSubChannelFactory

  PubSubChannel = require './channel'

  # Default channel name
  DEFAULT_NAME = 'root'

  # List of channels registered
  @channels = {}
  # Counts each channel instances
  @channelsCounters = {}

  ###
   * Creates a new pubsub channel
   * Only one is created by `channelName`
   * @param  {string} channelName = DEFAULT_NAME
   * @param  {Array} events Events to register
   * @return {PubSubChannel}
  ###
  @create = ( channelName = DEFAULT_NAME, events = [] ) ->
    # If channels exists, it's returned
    if !!@channels[channelName]
      @channels[channelName].registerEvents events
      @channelsCounters[channelName]++

      return @channels[channelName]

    # Channel created with basic events
    channel = new PubSubChannel channelName, events

    # Creates a destruction function
    channel.destroy = => @destroy channelName

    # Channel is savec in list
    @channels[channelName] = channel
    @channelsCounters[channelName] = 1

    return @channels[channelName]

  ###
   * Destroys `channelName` if no destroy is pending.
   * For instance, is the channel has been "created" 4 times,
   * it will only be destroyed on fourth destroy call
   * @param  {string} channelName
   * @return {undefined}
  ###
  @destroy = ( channelName = DEFAULT_NAME ) ->
    if 1 is @channelsCounters[channelName]--
      @channels[channelName].unregisterAllEvents()
      delete @channels[channelName]
      delete @channelsCounters[channelName]
    return


module.exports = PubSubChannelFactory
