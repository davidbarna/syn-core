/**
 * Overrides XMLHttpRequest class in order to have an integrated
 * cache system. In it, all necessary data for retry is saved.
**/

let XHRCacheSingletonInstance = null

export class XHRCache {

  constructor () {
    if (XHRCacheSingletonInstance) {
      return XHRCacheSingletonInstance
    }

    let XMLHttpRequest = window.XMLHttpRequest

    this.RealXHR = XMLHttpRequest
    this.open = XMLHttpRequest.prototype.open
    this.setRequestHeader = XMLHttpRequest.prototype.setRequestHeader

    XHRCacheSingletonInstance = this
  }

  enable () {
    this._overrideXHROpen()
    this._overrideXHRSetRequestHeader()
    this._overrideXHRConstructor()
    return this
  }

  disable () {
    window.XMLHttpRequest.prototype.setRequestHeader = this.setRequestHeader
    window.XMLHttpRequest.prototype.open = this.open
    window.XMLHttpRequest = this.RealXHR
  }

  /**
   * @returns {Object}
  **/
  getData () {
    return this.cachedXHRData
  }

  _overrideXHRConstructor () {
    /**
     * @param {Object} options
     * @param {boolean} options.enableCache Flag to enable param cache
     * @returns {XMLHttpRequest}
    **/
    window.XMLHttpRequest = (options = {}) => {
      this.cacheEnabled = !options.noXHRCache
      if (this.cacheEnabled) {
        this.cachedXHRData = {
          method: '',
          url: '',
          options: {
            headers: {}
          }
        }
      }
      return new this.RealXHR()
    }
  }

  _overrideXHROpen () {
    let self = this
    /**
     * @param {string} method
     * @param {string} url
     * @param {boolean} async
    **/
    window.XMLHttpRequest.prototype.open = function (method, url, async) {
      if (self.cacheEnabled) {
        self.cachedXHRData.method = method
        self.cachedXHRData.url = url
      }
      self.open.apply(this, [].slice.call(arguments))
    }
  }

  _overrideXHRSetRequestHeader () {
    let self = this
    /**
     * @param {string} headerName
     * @param {string} headerValue
    **/
    window.XMLHttpRequest.prototype.setRequestHeader = function (headerName, headerValue) {
      if (self.cacheEnabled) {
        self.cachedXHRData.options.headers[headerName] = headerValue
      }
      self.setRequestHeader.apply(this, [].slice.call(arguments))
    }
  }
}
