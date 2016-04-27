synCore =
  Config: require( './lib/config' )
  pubsub:
    Channel: require( './lib/pubsub/channel' )
    channel:
      factory: require( './lib/pubsub/channel-factory' )
  angularify: require( './lib/angularify' )
  i18n: require( './lib/i18n' ).i18n

if !!window
  window.syn ?= {}
  window.syn.core ?= synCore

if !!module
  module.exports = synCore
