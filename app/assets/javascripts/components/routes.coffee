{div} = React.DOM

Routes = React.createClass
  displayNmae: 'Routes'

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
    div null, "View: #{@state.props.filter}"

window.Routes = Routes
