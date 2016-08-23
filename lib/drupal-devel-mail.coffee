DrupalDevelMailTableView = require './views/drupal-devel-mail-table-view'

fs = require('fs')

{MailParser} = require('MailParser');

# {$} = require 'atom'
{CompositeDisposable} = require 'atom'
{Directory} = require 'atom'

module.exports = DrupalDevelMail =
  activate: (state) ->
    @drupalDevelMailView = new DrupalDevelMailTableView(state.drupalDevelMailViewState)
    @drupalDevelMailView.setColumnHeaders([
      'Creation date',
      'From',
      'To',
      'Subject'
    ]);

    # The Directory instance, which we'll use to observe the devel-mails folder
    @directory = new Directory '/tmp/devel-mails';
    @directory.create(0o775).then ((result) ->

      # Watch the folder for changes
      @directory.onDidChange @checkoutChangesDevelMail.bind(this)
    ).bind this


    # Register commands
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:reload-mail': => @updatePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:hide-panel': => @hidePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:show-panel': => @showPanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'drupal-devel-mail:toggle-panel': => @togglePanel()

    # Add the panel
    @modalPanel = atom.workspace.addBottomPanel(item: @drupalDevelMailView.getElement(), visible: false)

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

  parseMail: (file) ->

    promise = new Promise (resolve, reject) =>

      mailparser = new MailParser;
      mailparser.on("end", (mail) ->
        resolve({file: file, data: mail})
      )

      filePath = file.getPath()
      file.read(true).then (data) ->
        mailparser.write data
        mailparser.end()

    promise

  getAllMailData: ->
    promise = new Promise (resolve, reject) =>

      files = @getDevelMailsFiles()

      that = this;
      mails = []
      files.reduce ((promise, file, currentIndex, origArr) ->
        promise.then (->
          that.parseMail file
            .then((data) ->
              mails.push data
              if (currentIndex == origArr.length - 1)
                resolve(mails)
              return
            )
        )
      ), Promise.resolve()

  updatePanel: ->

    @getAllMailData().then((mails) =>
      tableData = [];
      for mail in mails

        file = mail.file
        data = mail.data

        filePath = file.getPath()
        fileStats = fs.statSync(filePath)
        fileCreationDate = new Date (fileStats.birthtime)

        tableData.push {
          uri: filePath,
          creationDate: fileCreationDate,
          columns: [
            fileCreationDate.getUTCDate() + '-' + (fileCreationDate.getUTCMonth() + 1) + '-' + fileCreationDate.getUTCFullYear() + ' ' + ("0" + fileCreationDate.getUTCHours()).slice(-2) + ':' + ("0" + fileCreationDate.getUTCMinutes()).slice(-2) + ':' + ("0" + fileCreationDate.getUTCSeconds()).slice(-2),
            data.from[0].address,
            data.to[0].address,
            data.subject
          ]
        }

      @drupalDevelMailView.empty()
      @drupalDevelMailView.setData tableData
      @drupalDevelMailView.update()
    )


    # content_elm = @drupalDevelMailView.getContentElement()
    # content_elm.innerHTML = ''
    # list_elm = new DrupalDevelMailListView()
    #
    # for file in files
    #   if file.isFile()
    #     list_item_elm = new DrupalDevelMailItemView()
    #     list_item_elm.setText file.getBaseName()
    #     list_item_elm.setIcon 'mail'
    #     list_item_elm.setURI file.getPath()
    #     list_elm.add list_item_elm.getElement()
    #
    # content_elm.appendChild list_elm.getElement()

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
