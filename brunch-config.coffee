exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      order:
        before: [
          'app/templates/*'
          'app/javascripts/router.coffee'
        ]
      joinTo:
        'javascripts/app.js': /^(?!templates)app(\/|\\)/
        'javascripts/vendor.js': /^(?!app)/
    stylesheets:
      joinTo: 'stylesheets/app.css'
    templates:
      joinTo: 'javascripts/app.js'

  # clean compiled js file from modules header and wrap it like coffeescript should
  modules:
    definition: false
    wrapper: false

  plugins:
    eco:
      namespace: "JST"
