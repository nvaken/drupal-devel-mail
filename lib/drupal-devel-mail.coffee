DrupalDevelMailView = require './views/drupal-devel-mail-view'
DrupalDevelMailListView = require './views/drupal-devel-mail-list-view'
DrupalDevelMailItemView = require './views/drupal-devel-mail-item-view'

# {$} = require 'atom'
{CompositeDisposable} = require 'atom'
{Directory} = require 'atom'

module.exports = DrupalDevelMail =
  activate: (state) ->
    @drupalDevelMailView = new DrupalDevelMailView(state.drupalDevelMailViewState)
    # @drupalDevelMailView.getCloseBtnElement()
    #   .onclick = @hidePanel.bind this

    @directory = new Directory '/tmp/devel-mails';
    @directory.onDidChange @updatePanel.bind(this)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:reload-mail': => @updatePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:hide-panel': => @hidePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:show-panel': => @showPanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:toggle-panel': => @togglePanel()

    @modalPanel = atom.workspace.addRightPanel(item: @drupalDevelMailView.getElement(), visible: false)

    @updatePanel()

  updatePanel: ->

    content_elm = @drupalDevelMailView.getContentElement()
    content_elm.innerHTML = ''
    list_elm = new DrupalDevelMailListView()

    files = @getDevelMailsFiles()
    for file in files
      if file.isFile()
        list_item_elm = new DrupalDevelMailItemView()
        list_item_elm.setText file.getBaseName()
        list_item_elm.setIcon 'mail'
        list_item_elm.setURI file.getPath()
        list_elm.add list_item_elm.getElement()

    content_elm.appendChild list_elm.getElement()

  getDevelMailsFiles: ->
    @directory.getEntriesSync();

  showPanel: ->
    @modalPanel.show()

  hidePanel: ->
    @modalPanel.hide()

  togglePanel: ->

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
