synCore =
  pubsub:
    Channel: require( './lib/pubsub/channel' )
    channel:
      factory: require( './lib/pubsub/channel-factory' )

if !!window
  window.syn ?= {}
  window.syn.core ?= synCore

if !!module
  module.exports = synCore
