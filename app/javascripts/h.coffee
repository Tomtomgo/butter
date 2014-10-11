window.H =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  init: ->
    console.debug 'Routerz'
    
    @router = new Router()
    @app = new Bargh()

    # Initialize History
    Backbone.history.start(pushState: true, hashChange: false)


$(document).ready ->
  H.init()