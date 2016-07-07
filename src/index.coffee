synCore =
  Config: require( './lib/config' )
  pubsub:
    Channel: require( './lib/pubsub/channel' )
    channel:
      factory: require( './lib/pubsub/channel-factory' )
  resource:
    Client: require( './lib/resource/client' )
    Url: require( './lib/resource/url' )
    interceptors:
      Handler: require( './lib/resource/interceptor/handler' ).InterceptorHandler
      TokenRefresher: require( './lib/resource/interceptor/token-refresher' )
  angularify: require( './lib/angularify' )
  i18n: require( './lib/i18n' ).i18n

if !!window
  window.syn ?= {}
  window.syn.core ?= synCore

if !!module
  module.exports = synCore
