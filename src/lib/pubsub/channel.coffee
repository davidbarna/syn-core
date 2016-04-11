###
#PubSubChannel

A simple object that registered new instances
of [pubsub](https://www.npmjs.com/package/pubsub)
on each event key.

This way, you can create a convention of basic events
common to your modules, that can be used to comunicate
easily in a private channel

```coffeescript
channel = new PubSubChannel 'my-private-channel'
channel.registerEvent 'fire'

class PoliceDept
  constuctor: (@channel) ->

  alertFire: (address) ->
    @channel.fire.publish address

class Fireman
  constuctor: (@channel) ->
    @channel.fire.subscribe @onFire

  onFire: (address) ->
    @goTo address
      .fightFire()

new Fireman channel
new PoliceDept(channel).alertFire('Plaza Universitat, 3, Barcelona')

```

###
class PubSubChannel

  pubsub = require 'pubsub'

  constructor: ( channelName, eventsNames = [] ) ->
    # Name of private channel
    @name = channelName
    # Events keys
    @events = []

    @registerEvents eventsNames

  ###
   * Registers a new event as a
   * [pubsub](https://www.npmjs.com/package/pubsub) instance
   * @param  {string} eventName
   * @return {this}
  ###
  registerEvent: ( eventName ) ->
    return if !!@[eventName]

    @events.push eventName
    @[eventName] = pubsub()
    return this

  ###
   * Registerr several events
   * @param  {Array.string} eventsNames
   * @return {undefined}
  ###
  registerEvents: ( eventsNames = [] ) ->
    @registerEvent eventName for eventName in eventsNames
    return

  ###
   * Removes all events/listeners
   * @return {undefined}
  ###
  unregisterAllEvents: ->
    delete @[eventName] for eventName in @events
    @events = []
    return



module.exports = PubSubChannel
