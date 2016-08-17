module.exports =
class DrupalDevelMailView
  constructor: (serializedState) ->

    # Create root element
    @element = document.createElement('atom-panel')
    @element.classList.add('drupal-devel-mail')
    @element.classList.add('padded')

    # Create content element
    @content = document.createElement('div')
    @content.classList.add('inset-panel')
    @content.classList.add('padded')
    @element.appendChild(@content)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  getContentElement: ->
    @content

  getCloseBtnElement: ->
    @close_btn
