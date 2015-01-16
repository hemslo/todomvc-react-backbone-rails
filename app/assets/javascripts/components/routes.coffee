#= require ./todo

Routes = React.createClass
  displayNmae: 'Routes'

  propTypes:
    todos: React.PropTypes.string.isRequired
    todos_path: React.PropTypes.string.isRequired

  getInitialState: ->
    view: 'Home'
    props:
      filter: 'all'

  componentDidMount: ->
    @router = new TodoApp.Routers.Todos()
    @router.on 'route:home', @_onHome
    Backbone.history.start() if not Backbone.History.started

  componentWillUnmount: ->
    Backbone.history.stop()

  _onHome: (filter) ->
    props = { filter: 'all' }
    props['filter'] = filter if filter in ['active', 'completed']
    console.log props
    @setState view: 'Home', props: props

  render: ->
    @["render#{@state.view}"]()

  renderHome: ->
    React.createElement Todo, _.extend({}, @props, @state.props)

window.Routes = Routes
