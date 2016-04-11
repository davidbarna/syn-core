module.exports =
  pubsub:
    Channel: require( './lib/pubsub/channel' )
    channel:
      factory: require( './lib/pubsub/channel-factory' )
