#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./routers

window.TodoApp =
  Models: {}
  Collections: {}
  Routers: {}
  Dispatcher: _.clone(Backbone.Events)
