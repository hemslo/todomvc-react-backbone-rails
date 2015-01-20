class TodoApp.Collections.Todos extends Backbone.Collection

  model: TodoApp.Models.Todo

  url: '/todos'

  comparator: 'id'

  isAllComplete: ->
    @every (todo) ->
      todo.get 'completed'

  completed: ->
    @where completed: true

  active: ->
    @where completed: false
