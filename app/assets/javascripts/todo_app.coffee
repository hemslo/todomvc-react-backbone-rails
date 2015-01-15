#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./routers

window.TodoApp =
  Models: {}
  Collections: {}
  Routers: {}
  initialize: -> console.log 'Hello from Backbone!'

$(document).ready ->
  TodoApp.initialize()
