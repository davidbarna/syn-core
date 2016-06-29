/**
 * Client request/response interceptor
**/
import pubsub from '../../../lib/pubsub/channel-factory'
const MAX_ATTEMPTS = 2
const REFRESH_URL = 'http://dev-api.grupoareas.com/stocks/v1.0/refresh'

let tokenRefresherSingletonInstance = null

/**
 * Adds the necessary interceptor for 419 response codes.
 * Will try to refresh the token and retries the last request
 * if it's successfully refreshed
 * @return {Promise}
**/
export function enable () {
  var tokenRefresher = new TokenRefresher()
  if (tokenRefresher.isEnabled()) {
    return
  }
  tokenRefresher.enable()
  let eventPublisher = pubsub.create('interceptors', ['add'])
  eventPublisher.add.publish({
    'response': function (req, resolve, reject) {
      // Response code is 419: Session expired.
      if (req.target && req.target.status === 419) {
        tokenRefresher.onSessionExpired(req, resolve, reject)
      } else {
        tokenRefresher.resetAttempts()
        return resolve(req)
      }
    }
  })
}

class TokenRefresher {

  /**
   * @return {Promise}
  **/
  constructor () {
    if (tokenRefresherSingletonInstance) {
      return tokenRefresherSingletonInstance
    }

    this.resetAttempts()
    this._addEventsListeners()

    this.xhrCache = new window.syn.core.resource.XHRCache()
      .enable()
    tokenRefresherSingletonInstance = this
  }

  /**
   * Returns true if the user has checked the login's remember me checkbox
   * @returns {boolean}
  **/
  isRememberActive () {
    return !!this.session && !!this.session.user() && this.session.user().remember()
  }

  /**
   * Listen to session changes
  **/
  _addEventsListeners () {
    let gSession = window.syn.auth.session.global
    gSession.on(gSession.CHANGE, (session) => {
      console.log('New session', session)
      this.session = session
    })
  }

  /**
   * Deep deleting the session object
  **/
  _clearSession () {
    let gSession = window.syn.auth.session.global
    gSession.clear()
  }

  resetAttempts () {
    this.attempts = 0
  }

  enable () {
    this._enabled = true
  }

  isEnabled () {
    return this._enabled
  }

  /**
   * @param {Object} opts Options
   * @param {string} opts.token
   * @param {string} opts.refresh_token
   * @param {number} opts.expires_in
   * @returns {PersistentSession}
  **/
  updateToken (opts = {}) {
    if (!this.session) return
    this.session.token(opts.access_token)
    this.session.expiresIn(opts.expires_in)
    this.session.refreshToken(opts.refresh_token)
  }

  /**
   * Does the API call which will refresh the token
   * @returns {Promise}
  **/
  refreshTokenRequest () {
    let refreshReq = new window.syn.auth.resource.Client(REFRESH_URL)
    let refreshToken = this.session.refreshToken()
    let opts = {
      headers: {
        'token': refreshToken
      },
      noXHRCache: true
    }

    return refreshReq.post(opts)
  }

  /**
   * Does a XMLHttpRequest based on the data passed as param
   * @param {Object} data
   * @return {Promise}
  **/
  retryRequest (data) {
    if (!data) {
      return
    }
    let retryReq = new window.syn.auth.resource.Client(data.url)
    return retryReq.request(data.method, data.options)
  }

  onSessionExpired (req, resolve, reject) {
    this.attempts++
    if (this.attempts === MAX_ATTEMPTS) {
      this._clearSession()
    } else if (this.isRememberActive()) {
      let self = this
      let lastXhrData = this.xhrCache.getData()
      this.refreshTokenRequest()
      .then(function (refreshResponse) {
        self.updateToken(refreshResponse.token)
        return self.retryRequest(lastXhrData)
      })
      .catch(function (error) {
        reject(error)
      })
    }
  }
}
