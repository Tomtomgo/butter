class Router extends Backbone.Router

  routes:
    # home
    '(/)': 'home'
    'compoz0r/:id(/)': 'comp'

  home: ->
    H.app.home()

  comp: (id) ->
    H.app.composer(id)