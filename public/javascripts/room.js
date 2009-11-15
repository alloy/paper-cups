if (typeof PC == "undefined") PC = {};

PC.Room = Class.create({
  initialize: function(container) {
    this.container = $(container);
    this.action = this.container.readAttribute('data-action');
    this.messagesTable = this.container.down('#messages');
    this.messagesTBody = this.messagesTable.down('tbody');
    
    this.start();
  },
  
  start: function() {
    if (this.action) {
      this.setupWindow();
      this.setupMuteCheckbox();
      this.setupRefreshedElements();
    }
    this.groupMessagesByAuthor();
  },
  
  setupWindow: function() {
    this.isVisible = true;
    this.originalTitle = document.title;
    Event.observe(window, 'blur',  this.windowLoosesFocus.bindAsEventListener(this));
    Event.observe(window, 'focus', this.windowGainsFocus.bindAsEventListener(this));
  },
  
  setupMuteCheckbox: function() {
    this.muteCheckbox = $('mute');
    this.muteCheckbox.observe('change', function() {
      this.muteCheckbox.up('form').request();
    }.bind(this));
  },
  
  setupRefreshedElements: function() {
    this.onlineMembersTBody = this.container.down('#online_members');
    
    this.newMessageForm = $('new_message');
    this.newMessageButton = this.newMessageForm.down('input[type=submit]');
    this.newMessageInput = this.newMessageForm.down('textarea');
    this.newMessageInput.focus();
    
    this.newMessageInput.observe('keypress', this.keyPressOnMessageInput.bindAsEventListener(this));
    this.newMessageForm.observe('submit', this.submitMessage.bindAsEventListener(this));
    
    this.startUpdateLoop();
  },
  
  keyPressOnMessageInput: function(event) {
    if (event.keyCode == Event.KEY_RETURN) {
      if (event.altKey) {
        event.stop();
        this.newMessageInput.value += "\n";
      } else {
        this.submitMessage(event);
      }
    }
  },
  
  startUpdateLoop: function() {
    this.timer = new PeriodicalExecuter(this.requestData.bindAsEventListener(this), 10);
  },
  
  windowLoosesFocus: function() {
    this.isVisible = false;
    this.messageCountBeforeFocusLost = this.messageCount();
  },
  
  windowGainsFocus: function() {
    document.title = this.originalTitle;
    this.isVisible = true;
  },
  
  messageCount: function() {
    return this.messagesTBody.select('tr').length;
  },
  
  lastMessage: function() {
    return this.messagesTBody.down('tr:last-child');
  },
  
  lastMessageId: function() {
    return this.lastMessage().readAttribute('data-message-id');
  },
  
  requestData: function() {
    new Ajax.Request(this.action, {
      method: 'get',
      parameters: { since: this.lastMessageId() },
      onSuccess: this.loadData.bindAsEventListener(this),
    });
  },
  
  submitMessage: function(event) {
    this.timer.stop();
    event.stop();
    
    this.newMessageButton.disabled = true;
    this.newMessageForm.request({
      parameters: { since: this.lastMessageId() },
      onSuccess: function(response) {
        this.newMessageInput.value = '';
        this.dontNotify = true;
        this.loadData(response);
      }.bind(this),
      onComplete: function() {
        this.newMessageButton.disabled = false;
        this.newMessageInput.focus();
        this.startUpdateLoop();
      }.bind(this),
    });
  },
  
  loadData: function(response) {
    var data = response.responseText.evalJSON();
    this.onlineMembersTBody.innerHTML = data.online_members;
    if (data.messages && !data.messages.strip().empty()) {
      this.messagesTBody.insert(data.messages);
      this.groupMessagesByAuthor();
      this.newMessageInput.scrollIntoView();
      this.notify();
    }
  },
  
  groupMessagesByAuthor: function() {
    var last_author;
    this.messagesTBody.select('tr').each(function(row) {
      var author = row.down('th');
      var author_id = author.readAttribute('data-author-id');
      if (last_author && author_id == last_author) { author.innerHTML = ''; }
      last_author = author_id;
    }, this);
  },
  
  notify: function() {
    if (this.dontNotify) {
      this.dontNotify = false;
    } else {
      if (!this.muteCheckbox.checked) {
        var existingBeep = document.body.down('embed');
        if (existingBeep) { existingBeep.remove(); }
        document.body.insert(PC.Room.BEEP_HTML);
      }
      if (!this.isVisible) {
        var count = this.messageCount() - this.messageCountBeforeFocusLost;
        document.title = '(' + count + ') ' + this.originalTitle;
      }
    }
  },
});

// Free sound effect from: http://www.freesoundfiles.tintagel.net/Audio/free-wave-files-beeps
PC.Room.BEEP_HTML = '<embed src="/droplet.wav" type="audio/wav" hidden="true" autostart="true" loop="false" volume="50" />';

PC.Room.watch = function() {
  var container = $('room');
  if (container) {
    return new PC.Room(container);
  }
}