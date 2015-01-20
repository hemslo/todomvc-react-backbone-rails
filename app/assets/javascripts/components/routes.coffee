#= require ./todo

Routes = React.createClass
  displayNmae: 'Routes'

  propTypes:
    todos: React.PropTypes.string.isRequired

  getInitialState: ->
    view: 'Home'
    props:
      filter: 'all'

  componentWillMount: ->
    @todos = new TodoApp.Collections.Todos(JSON.parse(@props.todos))
    @setState props: { filter: 'all', todos: @todos }
    @router = new TodoApp.Routers.Todos()
    @router.on 'route:home', @_onHome

  componentDidMount: ->
    Backbone.history.start() if not Backbone.History.started

  componentWillUnmount: ->
    Backbone.history.stop()

  _onHome: (filter) ->
    props = { filter: 'all', todos: @todos }
    props['filter'] = filter if filter in ['active', 'completed']
    @setState view: 'Home', props: props

  render: ->
    @["render#{@state.view}"]()

  renderHome: ->
    React.createElement Todo, _.extend({}, @props, @state.props)

window.Routes = Routes
