module.exports =
class DrupalDevelMailListView
  constructor: (serializedState) ->

    # Create root element
    @element = document.createElement('ul')
    @element.classList.add('list-group')

  add: (element) ->
    @element.appendChild element

  remove: (element) ->
    @element.find element
      .remove()

  getElement: ->
    @element
