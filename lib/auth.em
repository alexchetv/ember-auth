class Em.Auth
  init: ->
    # initialize the adapters
    for type in ['request', 'response', 'strategy', 'session']
      # allow only a string as config value
      msg    = "The `#{type}` config should be a string"
      config = @get type
      Em.assert msg, typeof config == 'string'

      # lookup the adapter
      containerType = "auth#{Em.string.classify type}"
      containerKey  = "#{containerType}:#{config}"
      adapter       = @container.lookup containerKey

      baseKlass = Em.string.classify containerType
      klass     = "#{Em.string.classify config}#{baseKlass}"

      # helpful error msg if not found in container
      msg = "The requested `#{config}` #{type}Adapter cannot be found. Either name it (YourApp).#{klass}, or register it in the container under `#{containerKey}`."
      Em.assert msg, adapter

      # helpful error msg if not extending from base class
      msg = "The requested `#{config}` #{type}Adapter must extend from Ember.Auth.#{baseKlass}"
      Em.assert msg, Em.Auth.get(baseKlass).detect adapter

      # initialize the adapter
      @set "_#{type}", adapter.create { auth: this }

    @_handlers =
      signInSuccess:  []
      signInError:    []
      signOutSuccess: []
      signOutError:   []
      sendSuccess:    []
      sendError:      []

  addHandler: (type, handler) ->
    # check for unrecognized handler types
    msg = "Handler type must be one of `signInSuccess`, `signInError`, `signOutSuccess`, `signOutError`, `sendSuccess`, `sendError`; you passed in `#{type}`"
    validTypes = [
      'signInSuccess'
      'signInError'
      'signOutSuccess'
      'signOutError'
      'sendSuccess'
      'sendError'
    ]
    Em.assert msg, type in validTypes

    # check for handler being a function
    msg = 'Handler must be a function'
    Em.assert msg, typeof handler == 'function'

    @_handlers[type].pushObject handler

  removeHandler: (type, handler) ->
    # check for unrecognized handler types
    msg = "Handler type must be one of `signInSuccess`, `signInError`, `signOutSuccess`, `signOutError`, `sendSuccess`, `sendError`; you passed in `#{type}`"
    validTypes = [
      'signInSuccess'
      'signInError'
      'signOutSuccess'
      'signOutError'
      'sendSuccess'
      'sendError'
    ]
    Em.assert msg, type in validTypes

    # check for handler being a function; or allow for undefined = remove all
    msg = 'Handler must be a function or omitted for removing all handlers'
    Em.assert msg, typeof handler == 'function' || typeof handler == 'undefined'

    if handler?
      @_handlers[type].removeObject handler
    else
      @_handlers[type] = []

  # =====================
  # Config
  # =====================

  request:  'jquery'
  response: 'json'
  strategy: 'token'
  session:  'cookie'

  # module
  modules: ['emberData']

  # request
  signInEndPoint: null  # req
  signOutEndPoint: null # req
  baseUrl: null

  # session
  userModel: null

  # strategy.token
  tokenKey: null # req
  tokenIdKey: null #req
  tokenLocation: 'param'
  tokenHeaderKey: null

  # module.actionRedirectable
  actionRedirectable:
    signInRoute: false # or string for route name
    signOutRoute: false # ditto
    signInSmart: false
    signOutSmart: false
    signInBlacklist: [] # list of routes that should redir to fallback
    signOutBlacklist: [] # ditto

  # module.authRedirectable
  authRedirectable:
    route: null

  # module.rememberable
  rememberable:
    tokenKey: null # req
    period: 14
    autoRecall: true
    endPoint: null

  # module.timeoutable
  timeoutable:
    period: 20 # mins
    callback: null # defaults to (auth).signOut()

  # module.urlAuthenticatable
  urlAuthenticatable:
    paramsKey: null # req
    endPoint: null
