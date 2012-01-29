Todo = Backbone.Model.extend
  defaults:
    done: false
  toggle: ->
    this.save done: not this.get('done')

TodoList = Backbone.Collection.extend
  model: Todo
  localStorage: new Store('todos')
  done: ->
    this.filter (todo) -> todo.get 'done'
  remaining: ->
    this.without.apply this, this.done()

# Views
TodoView = Backbone.View.extend
  model: Todo
  tagName: 'li'
  events:
    'change .check'           : 'toggleDone'
    'dblclick .todo-text'     : 'edit'
    'click .todo-destroy'     : 'destroy'
    'keypress .todo-input'    : 'updateOnEnter'
    'blur .todo-input'        : 'close'
  initialize: ->
    this.template = _.template $('#item-template').html()
    _.bindAll this, 'render', 'close', 'remove'
    this.model.bind 'change', this.render
    this.model.bind 'destroy', this.remove
  render: ->
    element = this.template this.model.toJSON()
    $(this.el).html element
    this.input = this.$('.todo-input')
    return this
  toggleDone: ->
    this.model.toggle()
  edit: ->
    $(this.el).addClass 'editing'
    this.input.focus()
  close: (e) ->
    this.model.save text: this.input.val()
    $(this.el).removeClass 'editing'
  updateOnEnter: (e) ->
    e.target.blur() if e.keyCode is 13
  remove: ->
    $(this.el).remove()
  destroy: ->
    this.model.destroy()

AppView = Backbone.View.extend
  collection: TodoList
  events:
    'keypress #new-todo'  : 'createOnEnter'
    'click .todo-clear a' : 'clearCompleted'
  initialize: ->
    _.bindAll this, 'addOne', 'addAll', 'render'
    this.input = this.$('#new-todo')
    this.collection.bind 'add', this.addOne
    this.collection.bind 'reset', this.addAll
    this.collection.fetch()
  addOne: (todo) ->
    view = new TodoView model: todo
    this.$('#todo-list').append view.render().el
  addAll: ->
    this.collection.each this.addOne
  createOnEnter: (e) ->
    return if e.keyCode isnt 13
    value = this.input.val()
    return if not value
    this.collection.create text: value
    this.input.val ''
  clearCompleted: ->
    _.each this.collection.done(), (todo) -> todo.destroy()
    return false
  
jQuery ($) ->
  App = new AppView
    el: $('#todoapp')
    collection: new TodoList
