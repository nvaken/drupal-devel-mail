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

    # The Directory instance, which we'll use to observe the devel-mails folder
    @directory = new Directory '/tmp/devel-mails';

    # Watch the folder for changes
    @directory.onDidChange @checkoutChangesDevelMail.bind(this)

    # Register commands
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:reload-mail': => @updatePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:hide-panel': => @hidePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:show-panel': => @showPanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:toggle-panel': => @togglePanel()

    # Add the panel
    @modalPanel = atom.workspace.addRightPanel(item: @drupalDevelMailView.getElement(), visible: false)

    @updatePanel()

  checkoutChangesDevelMail: () ->
    atom.notifications.addInfo \
      'New contents in the /tmp/devel-mails folder',
        {
          'detail': 'Usually means new e-mail.',
          'icon': 'mail'
        }

    @updatePanel()
    @showPanel()

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
