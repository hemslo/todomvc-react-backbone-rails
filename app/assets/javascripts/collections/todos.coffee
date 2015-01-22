class TodoApp.Collections.Todos extends Backbone.Collection

  model: TodoApp.Models.Todo

  initialize: ->
    super
    @registerDispatcher()

  url: '/todos'

  comparator: 'id'

  actions:
    add: (title) ->
      @create { title: title, completed: false }, { wait: true }

    toggle: (id) ->
      @get(id).toggle()

    toggleAll: (checked) ->
      todos = if checked then @active() else @completed()
      todos.forEach (todo) ->
        todo.toggle()

    save: (id, attrs) ->
      @get(id).save(attrs, { wait: true })

    destroy: (id) ->
      @get(id).destroy(wait: true)

    clearCompleted: ->
      @completed().forEach (todo) ->
        todo.destroy wait: true

  isAllComplete: ->
    @every (todo) ->
      todo.get 'completed'

  completed: ->
    @where completed: true

  active: ->
    @where completed: false

  registerDispatcher: ->
    for action, callback of @actions
      @listenTo TodoApp.Dispatcher, action, callback
