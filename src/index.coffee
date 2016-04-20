synCore =
  Config: require( './lib/config' )
  pubsub:
    Channel: require( './lib/pubsub/channel' )
    channel:
      factory: require( './lib/pubsub/channel-factory' )
  angularify: require( './lib/angularify' )


if !!window
  window.syn ?= {}
  window.syn.core ?= synCore

if !!module
  module.exports = synCore
