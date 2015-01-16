{header, h1, input, label, ul, li, div
, button, section, span, strong, footer, a} = React.DOM
{classSet, LinkedStateMixin, update} = React.addons

ENTER_KEY = 13
ESCAPE_KEY = 27

Todo = React.createClass
  displayName: 'Todo'
  mixins: [classSet, LinkedStateMixin, update]

  propTypes:
    filter: React.PropTypes.oneOf(['all', 'active', 'completed']).isRequired
    todos: React.PropTypes.string.isRequired
    todos_path: React.PropTypes.string.isRequired

  getInitialState: ->
    todos: @_sort(JSON.parse(@props.todos))
    newTodoTitle: ''
    editing: null
    editText: ''

  addTodo: (title) ->
    $.ajax
      type: 'POST'
      url: @props.todos_path
      data: { todo: { title: title, completed: false } }
      dataType: 'json'
    .done (data) =>
      @setState todos: @_sort(update(@state.todos, $push: [data]))
    .fail (xhr, status, err) ->
      console.error @props.todos_path, status, err.toString()

  toogle: (item) ->
    @_update item, completed: !item.completed
    .done (data) =>
      @setState todos: @_replaceTodos([
        index: @state.todos.indexOf(item)
        data: data
      ])
    .fail (xhr, status, err) ->
      console.error status, err.toString()

  toogleAll: (checked) ->
    todos = if checked then @activeTodos() else @completedTodos()
    $.when
    .apply null, todos.map (todo) =>
      @_update todo, completed: checked
    .done (results...) =>
      if results.length == 3
        results = [results] if typeof(results[1]) is 'string'
      @setState todos: @_replaceTodos(results.map (result) =>
        for todo, i in @state.todos
          return { index: i, data: result[0] } if result[0].id is todo.id
      )

  save: (item, attrs) ->
    @_update item, attrs
    .done (data) =>
      @setState todos: @_replaceTodos([
        index: @state.todos.indexOf(item)
        data: data
      ])
    .fail (xhr, status, err) ->
      console.error status, err.toString()

  destroy: (item) ->
    $.ajax
      type: 'DELETE'
      url: @_todo_path(item)
      dataType: 'json'
    .done =>
      @setState todos: @_sort(@state.todos.filter (todo) ->
        todo != item
      )

  clearCompleted: ->
    $.when
    .apply null, @completedTodos().map (todo) =>
      $.ajax
        type: 'DELETE'
        url: @_todo_path(todo)
        dataType: 'json'
    .then =>
      @setState todos: @activeTodos()

  isAllComplete: ->
    @state.todos.every (todo) ->
      todo.completed

  activeTodos: ->
    @state.todos.filter (todo) ->
      !todo.completed

  completedTodos: ->
    @state.todos.filter (todo) ->
      todo.completed

  _update: (todo, attrs) ->
    $.ajax
      type: 'PUT'
      url: @_todo_path(todo)
      data: { todo: update(todo, $merge: attrs) }
      dataType: 'json'

  _sort: (todos) ->
    todos.sort (a, b) ->
      a.id - b.id

  _replaceTodos: (mappings) ->
    @_sort update(@state.todos, $splice: mappings.map (mapping) ->
      [mapping.index, 1, mapping.data]
    )

  _todo_path: (todo) ->
    @props.todos_path + "/#{todo.id}"

  handleNewTodoKeyDown: (event) ->
    return if event.which != ENTER_KEY
    val = @state.newTodoTitle.trim()
    @addTodo(val) if val
    @setState newTodoTitle: ''

  handleToggle: (item) ->
    @toogle item

  handleToggleAll: (event) ->
    @toogleAll event.target.checked

  handleEdit: (item) ->
    @setState editing: item, editText: item.title

  handleEditKeyDown: (event) ->
    if event.which is ESCAPE_KEY
      @setState editText: '', editing: null
    else if event.which is ENTER_KEY
      @handleEditSubmit event

  handleDestroyButtonClick: (item) ->
    @destroy item

  handleEditSubmit: (event) ->
    return unless @state.editing
    val = @state.editText.trim()
    if val
      @save @state.editing, title: val
    else
      @destroy @state.editing
    @setState editText: '', editing: null

  handleClearCompleted: (event) ->
    @clearCompleted()

  render: ->
    div null,
      @renderHeader()
      @renderSection() if @state.todos.length
      @renderFooter() if @state.todos.length

  renderHeader: ->
    header id: 'header',
      h1 null, 'todos'
      input
        id: 'new-todo'
        placeholder: 'What needs to be done?'
        autoFocus: true
        onKeyDown: @handleNewTodoKeyDown
        valueLink: @linkState('newTodoTitle')

  renderSection: ->
    section id: 'main',
      input
        id: 'toggle-all'
        type: 'checkbox'
        checked: @isAllComplete()
        onChange: @handleToggleAll
      label htmlFor: 'toggle-all', 'Mark all as complete'
      ul id: 'todo-list', @renderTodoItems()

  renderTodoItems: ->
    todos = switch @props.filter
      when 'active' then @activeTodos()
      when 'completed' then @completedTodos()
      else @state.todos
    (@renderTodoItem(item) for item in todos)

  renderTodoItem: (item) ->
    classes = classSet
      completed: item.completed
      editing: item is @state.editing
    li { key: item.id, className: classes },
      div className: 'view',
        input
          className: 'toggle'
          type: 'checkbox'
          checked: item.completed
          onChange: @handleToggle.bind(@, item)
        label onDoubleClick: @handleEdit.bind(@, item),
          item.title
        button
          className: 'destroy'
          onClick: @handleDestroyButtonClick.bind(@, item)
      input
        className: 'edit'
        valueLink: @linkState('editText')
        onKeyDown: @handleEditKeyDown
        onBlur: @handleEditSubmit

  renderFooter: ->
    activeCount = @activeTodos().length
    completedCount = @state.todos.length - activeCount
    footer id: 'footer',
      span id: 'todo-count',
        strong null, activeCount
        " item#{if activeCount is 1 then '' else 's'} left"
      ul id: 'filters', @renderFilters()
      @renderClearCompletedButton(completedCount) if completedCount

  renderFilters: ->
    items = [
      { filter: 'all', href: '#/', val: 'All' }
      { filter: 'active', href: '#/active', val: 'Active' }
      { filter: 'completed', href: '#/completed', val: 'Completed' }
    ]
    items.map (item) =>
      props = { href: item.href }
      props['className'] = 'selected' if @props.filter is item.filter
      li key: item.filter,
        a props, item.val

  renderClearCompletedButton: (completedCount) ->
    button
      id: 'clear-completed'
      onClick: @handleClearCompleted
      , "Clear completed (#{completedCount})"

window.Todo = Todo
