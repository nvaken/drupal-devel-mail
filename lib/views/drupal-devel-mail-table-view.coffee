module.exports =
class DrupalDevelMailTableView
  constructor: (serializedState) ->

    # Create root element
    @element = document.createElement('atom-panel')
    @element.classList.add('drupal-devel-mail')
    @element.classList.add('padded')

    @content = document.createElement('div')
    @content.classList.add('inset-panel')
    @content.classList.add('padded')
    @content.appendChild @createTableElement()

    @element.appendChild(@content)


  createTableElement: ->
    @tableElement = document.createElement('table')
    @tableElement.classList.add 'table'
    @tableElement.classList.add 'table-condensed'

    @tableBodyElement = document.createElement('tbody')
    @tableElement.appendChild @tableBodyElement
    @tableElement

  empty: ->
    # Why not innerHTML = ''? @see http://stackoverflow.com/a/3955238
    i = 0;
    while @tableBodyElement.firstChild
      @tableBodyElement.removeChild @tableBodyElement.firstChild
      i++
    i

  setData: (data) ->
    data.sort((a, b) ->
      b.creationDate - a.creationDate
    );
    @data = data

  setColumnHeaders: (data) ->
    @columnHeaderData = data

  createColumnHeaders: ->
    row = @createRow()
    data = @columnHeaderData
    for header in data
      column = @createColumn(true)
      column.innerHTML = header
      row.appendChild column
    row

  update: ->

    # Set table headers
    @tableBodyElement.appendChild @createColumnHeaders()

    i = 0
    data = @data
    for dataRow in data
      row = @createRow dataRow
      row.mailFileURI = dataRow.uri
      row.onclick = ->
        atom.workspace.open @mailFileURI

      for dataColumn in dataRow.columns
        column = @createColumn()
        column.innerHTML = dataColumn
        row.appendChild column

      i++
      @tableBodyElement.appendChild row
    i

  createRow: () ->
    document.createElement('tr')

  createColumn: (header = false) ->
    if (header == false)
      document.createElement('td')
    else
      document.createElement('th')

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
