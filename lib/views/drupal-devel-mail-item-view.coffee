module.exports =
class DrupalDevelMailItemView
  constructor: (serializedState) ->

    @uri = ''

    # Create root element
    @element = document.createElement 'li'
    @element.classList.add 'list-item'

    @content_elm = document.createElement 'a'
    @content_elm.classList.add 'icon'
    @element.onclick = @openURI
      .bind(this)
    @element.appendChild @content_elm

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  setText: (text) ->
    @content_elm.innerHTML = text

  setIcon: (icon) ->
    @content_elm.classList.add 'icon-' + icon

  setURI: (uri) ->
    @uri = uri

  getURI: ->
    @uri

  openURI: ->
    atom.workspace.open @getURI()
