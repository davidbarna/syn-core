fdescribe 'i18n', ->

  core = require( 'src/index' )
  instance = fooInstance = testInstance = null

  # Cached vars
  LANG_ES = 'es'
  LANG_EN = 'en'

  TEXT_EN_TITLE = 'Title'
  TEXT_EN_TXT = 'Text'
  TEXT_EN_NOT_TRANSLATED = 'Not translated'
  TEXT_EN_WITH_PARAMS = 'Mr. %1 got %2 gems. Did I said %1?'
  TEXT_ES_TITLE = 'Título'
  TEXT_ES_TXT = 'Texto'
  TEXT_ES_WITH_PARAMS = 'El Sr. %1 tiene %2 gemas. ¿Dije %1?'

  # Fake data
  textsEN = {
    'TEST_TITLE': TEXT_EN_TITLE
    'TEST_TXT': TEXT_EN_TXT
    'TEST_NOT_TRANSLATED': TEXT_EN_NOT_TRANSLATED
    'TEST_WITH_PARAMS': TEXT_EN_WITH_PARAMS
  }
  textsES = {
    'TEST_TITLE': TEXT_ES_TITLE
    'TEST_TXT': TEXT_ES_TXT
    'TEST_WITH_PARAMS': TEXT_ES_WITH_PARAMS
  }

  isFunction = ( it ) ->
    return Object.prototype.toString.call(it) is '[object Function]'

  beforeEach ->
    core.i18n.setLanguage( 'en' )

    instance = core.i18n.getInstance()
    instance.translations( 'en', textsEN )
    instance.translations( 'es', textsES )

    testInstance = core.i18n.getInstance( 'test' )
    testInstance.translations( 'en', textsEN )
    testInstance.translations( 'es', textsES )

    fooInstance = core.i18n.getInstance( 'foo' )
    fooInstance.translations( 'en', textsEN )
    fooInstance.translations( 'es', textsES )

    @sandbox = sinon.sandbox.create()

  afterEach  ->
    core.i18n.removeAll()
    @sandbox.restore()
    instance = fooInstance = testInstance = null

  describe '#Constructor', ->

    it 'should return a new instance if the ID is not specified', ->
      expect( core.i18n.getInstance() ).to.not.be.equal( core.i18n.getInstance() )

    it 'should return the same instance if the ID is specified', ->
      expect( core.i18n.getInstance( 'test' ) )
        .to.be.equal( core.i18n.getInstance( 'test' ) )

    it 'should return different instances for each ID', ->
      expect( core.i18n.getInstance( 'unit' ) )
        .to.not.be.equal( core.i18n.getInstance( 'test' ) )

  describe '#i18n.removeInstance', ->

    it 'should remove the specified instance', ->


      core.i18n.removeInstance( 'test' )
      expect( core.i18n.getInstance( 'test' ) ).to.not.be.equal testInstance
      expect( core.i18n.getInstance( 'foo' ) ).to.be.equal fooInstance

  describe '#i18n.removeAll', ->

    it 'should remove all the instances', ->
      core.i18n.removeAll()
      expect( core.i18n.getInstance( 'test' ) ).to.not.be.equal testInstance
      expect( core.i18n.getInstance( 'foo' ) ).to.not.be.equal fooInstance

  describe 'i18n setLanguage', ->

    it 'should return false if the language is not an string', ->
      expect( core.i18n.setLanguage( null ) ).to.be.equal( false )

    it 'should set the language', ->
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      core.i18n.setLanguage( 'es' )
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )

    it 'should change all the instances languages', ->
      expect( testInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      expect( fooInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )

      core.i18n.setLanguage( 'es' )
      expect( testInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )
      expect( fooInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )

  describe '#i18n API', ->

    it 'should be an object', ->
      expect( typeof instance ).to.be.equal 'object'

    it 'should have a "translations" method', ->
      expect( isFunction( instance.translations ) ).to.be.true

    it 'should have a "setLanguage" method', ->
      expect( isFunction( instance.setLanguage ) ).to.be.true

    it 'should have a "translate" method', ->
      expect( isFunction( instance.translate ) ).to.be.true

  describe 'i18n translations', ->

    newTextsEN = { 'TEST_ADDED': 'added' }

    beforeEach ->
      instance.setLanguage( 'en' )

    it 'should return false if the language is incorrect', ->
      expect( instance.translations( undefined, textsEN ) ).to.be.equal( false )

    it 'should return false if the translations format is incorrect', ->
      expect( instance.translations( 'en', 'string' ) ).to.be.equal( false )

    it 'should return true if data has been saved', ->
      expect( instance.translations( 'en', textsEN ) ).to.be.equal( true )

    it 'should store the translations', ->
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      expect( instance.translate( 'TEST_TXT' ) ).to.be.equal( TEXT_EN_TXT )

    it 'should add the new translation', ->
      instance.translations( 'en', newTextsEN )
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      expect( instance.translate( 'TEST_TXT' ) ).to.be.equal( TEXT_EN_TXT )
      expect( instance.translate( 'TEST_ADDED' ) ).to.be.equal( 'added' )

  describe 'i18n setLanguage', ->

    it 'should return false if the language is not an string', ->
      expect( instance.setLanguage( null ) ).to.be.equal( false )

    it 'should set the language', ->
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      instance.setLanguage( 'es' )
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )

    it 'should change all the instances languages', ->
      expect( testInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      expect( fooInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )

      instance.setLanguage( 'es' )
      expect( testInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )
      expect( fooInstance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )

  describe 'i18n translate', ->

    it 'should return the msgid if the text does not exist', ->
      expect( instance.translate( 'FOO' ) ).to.be.equal( 'FOO' )

    it 'should return the default language text if the translation does not exist', ->
      instance.setLanguage( 'es' )
      expect( instance.translate( 'TEST_NOT_TRANSLATED' ) )
        .to.be.equal( TEXT_EN_NOT_TRANSLATED )

    it 'should return the translated text if the translation exists', ->
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_EN_TITLE )
      instance.setLanguage( 'es' )
      expect( instance.translate( 'TEST_TITLE' ) ).to.be.equal( TEXT_ES_TITLE )

    it 'should add the params to the text', ->

      expect( instance.translate( 'TEST_WITH_PARAMS', ['Mark', '12'] ) )
        .to.be.equal( 'Mr. Mark got 12 gems. Did I said Mark?' )
      
      instance.setLanguage( 'es' )
      expect( instance.translate( 'TEST_WITH_PARAMS', ['Marc', '8'] ) )
        .to.be.equal( 'El Sr. Marc tiene 8 gemas. ¿Dije Marc?')
