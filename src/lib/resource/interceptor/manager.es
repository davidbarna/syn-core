/**
 * Used to intercept and modify method responses.
 *
 * NOTE: Think about the interceptors as if they were DOM events
 * using an event delegation pattern.
 *
 * If you add two listeners to the same event, the delegator will call both
 * listeners and some listener could overwrite whatever the first listener has made.
 *
 * Same happens with the interceptors. Ideally we should only have one
 * interceptor per "operation".
 *
 * IMPORTANT:
 * - An interceptor should NOT depend on other interceptors modifications.
 * - An interceptor always has to resolve or reject.
 * -- The interceptor will receive: the data object and the resolve/reject functions.
 *    Interceptors can modify the data or replace the data with something different.
 *    The final data needs to be sent as a param when calling the resolve (resolve(data)).
 * -- If the interceptor is NOT interested in the input, it should resolve(null).
 *
 * Example of usage:
 *
 *  var interceptor = new Interceptor()
 *
 *  // Adding an interceptor.
 *  interceptor.add({
 *    'response': function (data, resolve, reject) {
 *      if (data.target.status !== 419) {
 *        // Not interested.
 *        resolve(null)
 *        return
 *      }
 *      _refreshLogin(data).then((newData) => {
 *        resolve(newData)
 *      })
 *    }
 *  })
 *
 *  xhr.addEventListener('load', ( response ) => {
 *    // Calling the interceptors.
 *    interceptor.process( 'response', response ).then( (response) => {
 *      // "response" could be the original response, or a modified response
 *      // by any interceptor.
 *      processResponse(response)
 *    }).catch((error) => { // If some interceptor has rejected his promise.
 *      reject(error)
 *    })
 *  })
 */

import pubsub from '../../../lib/pubsub/channel-factory'
import {Promise} from 'bluebird'
import {_} from 'underscore'

export class InterceptorManager {

  constructor () {
    if (this.instance) {
      return this.instance
    }

    this._interceptors = []
    this.instance = this
    this._listenOnAddEvent()
  }

  /**
   * Calls all the interceptors that are listening to
   * the passed method.
   * @param {string} method
   * @param {*} data
   * @returns {Promise}
   */
  process (method, data) {
    let promises = []

    this._iterateInterceptors((interceptor) => {
      if (interceptor[method]) {
        // Creates one promise per each interceptor.
        let promise = new Promise((resolve, reject) => {
          interceptor[method](data, resolve, reject)
        })
        promises.push(promise)
      }
      return
    })

    /**
     * When all the interceptors have resolved his promise
     * all the responses are checked.
     * If a response data is not null and it's different from
     * the original data, it is returned instead of the original data.
     */
    return Promise
      .all(promises)
      .then(function (responses) {
        let newData
        for (let i = 0, l = responses.length; i < l; i++) {
          if (responses[i] !== null && !_.isEqual(responses[i], data)) {
            newData = responses[i]
          }
        }
        return newData || data
      })
  }

  /**
   * Adds an interceptor.
   * @param {object} interceptor
   * @returns
   */
  add (interceptor) {
    if (typeof interceptor !== 'object' || interceptor === null) {
      console.warn('Interceptor.add: Invalid interceptor.')
      return false
    }
    this._interceptors.push(interceptor)
  }

  /**
   * Removes an interceptor.
   * @param {object} interceptor
   * @returns
   */
  remove (interceptor) {
    this._iterateInterceptors((current, position) => {
      if (current === interceptor) {
        this._interceptors.splice(position, 1)
      }
    })
  }

  /**
   * Iterates all the interceptors.
   * @param {function} callback
   * @returns
   */
  _iterateInterceptors (callback) {
    for (let i = 0, l = this._interceptors.length; i < l; i++) {
      callback(this._interceptors[i], i)
    }
  }

  _listenOnAddEvent () {
    this.pubsub = pubsub.create('interceptors', ['add'])
    this.pubsub.add.subscribe((interceptor) => this.add(interceptor))
  }
}
