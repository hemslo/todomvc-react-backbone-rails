{header, h1, input, label, ul, li, div
, button, section, span, strong, footer, a} = React.DOM
{classSet, LinkedStateMixin} = React.addons
dispatcher = TodoApp.Dispatcher

ENTER_KEY = 13
ESCAPE_KEY = 27

Todo = React.createClass
  displayName: 'Todo'
  mixins: [LinkedStateMixin]

  propTypes:
    filter: React.PropTypes.oneOf(['all', 'active', 'completed']).isRequired
    todos: React.PropTypes.object.isRequired

  getInitialState: ->
    todos: @props.todos.toJSON()
    newTodoTitle: ''
    editing: null
    editText: ''

  componentDidMount: ->
    @props.todos.on 'add change remove', @_onChange, @

  componentWillUnmount: ->
    @props.todos.off null, null, @

  _onChange: ->
    @setState todos: @props.todos.toJSON()

  handleNewTodoKeyDown: (event) ->
    return if event.which != ENTER_KEY
    val = @state.newTodoTitle.trim()
    dispatcher.trigger('add', val) if val
    @setState newTodoTitle: ''

  handleToggle: (id) ->
    dispatcher.trigger 'toggle', id

  handleToggleAll: (event) ->
    dispatcher.trigger 'toggleAll', event.target.checked

  handleEdit: (item) ->
    @setState editing: item.id, editText: item.title

  handleEditKeyDown: (event) ->
    if event.which is ESCAPE_KEY
      @setState editText: '', editing: null
    else if event.which is ENTER_KEY
      @handleEditSubmit event

  handleDestroyButtonClick: (id) ->
    @destroy id

  handleEditSubmit: (event) ->
    return unless @state.editing
    val = @state.editText.trim()
    if val
      dispatcher.trigger 'save', @state.editing, title: val
    else
      dispatcher.trigger 'destroy', @state.editing
    @setState editText: '', editing: null

  handleClearCompleted: (event) ->
    dispatcher.trigger 'clearCompleted'

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
        checked: @props.todos.isAllComplete()
        onChange: @handleToggleAll
      label htmlFor: 'toggle-all', 'Mark all as complete'
      ul id: 'todo-list', @renderTodoItems()

  renderTodoItems: ->
    @state.todos.map (todo) =>
      switch @props.filter
        when 'all' then @renderTodoItem(todo)
        when 'active'
          @renderTodoItem(todo) if !todo.completed
        when 'completed'
          @renderTodoItem(todo) if todo.completed

  renderTodoItem: (item) ->
    classes = classSet
      completed: item.completed
      editing: item.id is @state.editing
    li { key: item.id, className: classes },
      div className: 'view',
        input
          className: 'toggle'
          type: 'checkbox'
          checked: item.completed
          onChange: @handleToggle.bind(@, item.id)
        label onDoubleClick: @handleEdit.bind(@, item),
          item.title
        button
          className: 'destroy'
          onClick: @handleDestroyButtonClick.bind(@, item.id)
      input
        className: 'edit'
        valueLink: @linkState('editText')
        onKeyDown: @handleEditKeyDown
        onBlur: @handleEditSubmit

  renderFooter: ->
    activeCount = @props.todos.active().length
    completedCount = @props.todos.length - activeCount
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
      , "Clear completed"

window.Todo = Todo
