/**
 * Default language.
 * @type {string}
 */
const DEFAULT_LANGUAGE = 'en'

/**
 * Pattern to detect params in a string.
 * @type {Regexp}
 */
let paramsPattern = /%(\d+)/g

/**
 * To store all the created instances.
 * @type {Object}
 */
let instances = {}

/**
 * Current language. Shared by all the instances.
 * @type {String}
 */
let language = DEFAULT_LANGUAGE

/**
 * Public API.
 * @type {Object}
 */
class I18N {

  /**
   * Creates an i18n instance.
   * If the ID is specified returns a singleton for each ID.
   * If the ID is not specified returns a new instance.
   * @param {string} id Instance ID. Optional.
   */
  constructor (id) {
    let isValidId = typeof id === 'string'

    if (!!isValidId && !!instances[id]) {
      return instances[id]
    } else if (!!isValidId && !instances[id]) {
      instances[id] = this
    }

    /**
     * Object where the translations are stored.
     * @type {Object}
     */
    this._translations = {}
  }

  /**
   * Sets the translations for a language.
   * @param {string} lang Language identifier.
   * @param {object} translations
   * @returns {boolean} true if all went ok. false if not.
   */
  translations (lang, translations) {
    if (!this._isValidLanguage(lang) || !this._areValidTexts(translations)) {
      console.warn('i18n.translations: Invalid language or translations.')
      return false
    }

    if (!this._languageExists(lang)) {
      this._translations[lang] = {}
    }

    this._addTranslationsToLanguage(lang, translations)

    return true
  }

  /**
   * Sets the active language.
   * @param {string} lang
   * @returns {boolean}
   */
  setLanguage (lang) {
    if (!this._isValidLanguage(lang)) {
      console.warn('i18n.setLanguage: Invalid language.')
      return false
    }
    language = lang
    return true
  }

  /**
   * returns the translated text if exist.
   * @param {string} msgid Text identifier.
   * @param {array} params
   */
  translate (msgid, params) {
    let text = this._getTranslation(msgid)

    if (!Array.isArray(params) || params.length === 0) {
      return text
    }

    return this._replaceParams(text, params)
  }

  /**
   * Checks if a language is valid.
   * @param {string} lang
   * @returns {boolean}
   */
  _isValidLanguage (lang) {
    return typeof lang === 'string'
  }

  /**
   * Checks if a language exists.
   * @param {string} lang
   * @returns {boolean}
   */
  _languageExists (lang) {
    return this._isValidLanguage(lang) && this._areValidTexts(this._translations[lang])
  }

  /**
   * Checks if the translations are valid.
   * @param {object} translations
   * @returns {boolean}
   */
  _areValidTexts (translations) {
    return typeof translations === 'object' && translations !== null
  }

  /**
   * Adds new translation to the language.
   * @param {string} lang
   * @param {object} translations
   * @returns {boolean}
   */
  _addTranslationsToLanguage (lang, translations) {
    for (let key in translations) {
      if (translations.hasOwnProperty(key)) {
        this._translations[lang][key] = translations[key]
      }
    }
  }

  /**
   * Returns the translation for the given msgid.
   * @param {string} msgid
   * @returns {string}
   */
  _getTranslation (msgid) {
    if (this._languageExists(language) && typeof this._translations[language][msgid] !== 'undefined') {
      return this._translations[language][msgid]
    }

    if (this._languageExists(DEFAULT_LANGUAGE) && typeof this._translations[DEFAULT_LANGUAGE][msgid] !== 'undefined') {
      return this._translations[DEFAULT_LANGUAGE][msgid]
    }

    return msgid
  }

  /**
   * Replaces the text variables with its values and returns the final text.
   * @param {string} text
   * @param {object} params
   * @returns {string}
   */
  _replaceParams (text, params) {
    return text.replace(paramsPattern, function (v, n) {
      return (n >= 1 && n <= params.length) ? params[n - 1] : v
    })
  }
}

/**
 * Public API.
 * @type {Object}
 */
export var i18n = {
  /**
   * Returns an existant instance or creates a new one.
   * @param {string} id
   * @returns {I18N}
   */
  getInstance: function (id) {
    return instances[id] || new I18N(id)
  },

  /**
   * Sets the active language.
   * @param {string} lang
   * @returns {boolean}
   */
  setLanguage: I18N.prototype.setLanguage.bind(I18N.prototype),

  /**
   * Removes an instance from the collection.
   * @param {string} id
   */
  removeInstance: function (id) {
    if (instances[id]) {
      delete instances[id]
    }
  },

  /**
   * Removes all the instances from the collection.
   */
  removeAll: function () {
    instances = {}
  }
}
