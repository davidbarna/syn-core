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
      Handler: require( './lib/resource/interceptor/manager' ).InterceptorHandler
      TokenRefresher: require( './lib/resource/interceptor/refresh' )
  angularify: require( './lib/angularify' )
  i18n: require( './lib/i18n' ).i18n
  Messaging: require( './lib/messaging' ).default
  messaging:
    ui:
      Interface: require( './lib/messaging/ui/interface' ).default
      
if !!window
  window.syn ?= {}
  window.syn.core ?= synCore

if !!module
  module.exports = synCore
