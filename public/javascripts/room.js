if (typeof PC == "undefined") PC = {};

Event.KEY_ALT = 18;

PC.Room = Class.create({
  initialize: function(container) {
    this.container = $(container);
    this.action = this.container.readAttribute('data-action');
    this.messagesTable = this.container.down('#messages');
    this.messagesTBody = this.messagesTable.down('tbody');
    this.muteCheckbox = $('mute');
    
    this.start();
  },
  
  start: function() {
    this.setupWindow();
    this.setupRefreshedElements();
    this.groupMessagesByAuthor();
  },
  
  setupWindow: function() {
    this.isVisible = true;
    this.originalTitle = document.title;
    Event.observe(window, 'blur',  this.windowLoosesFocus.bindAsEventListener(this));
    Event.observe(window, 'focus', this.windowGainsFocus.bindAsEventListener(this));
  },
  
  setupRefreshedElements: function() {
    this.onlineMembersTBody = this.container.down('#online_members');
    
    this.newMessageForm = $('new_message');
    this.newMessageButton = this.newMessageForm.down('input[type=submit]');
    this.newMessageInput = this.newMessageForm.down('textarea');
    this.newMessageInput.focus();
    
    this.newMessageInput.observe('keyup', this.keyUpOnMessageInput.bindAsEventListener(this));
    this.newMessageInput.observe('keydown', this.keyDownOnMessageInput.bindAsEventListener(this));
    this.newMessageForm.observe('submit', this.submitMessage.bindAsEventListener(this));
    
    this.startUpdateLoop();
  },
  
  keyUpOnMessageInput: function(event) {
    if (event.keyCode == Event.KEY_ALT) {
      this.altKeyDown = false;
    }
  },
  
  keyDownOnMessageInput: function(event) {
    switch (event.keyCode) {
      case Event.KEY_ALT:
        this.altKeyDown = true;
        break;
      case Event.KEY_RETURN:
        if (this.altKeyDown) {
          this.altKeyDown = false;
        } else {
          this.submitMessage(event);
        }
        break;
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
        document.body.insert(PC.Room.beepHTML);
      }
      if (!this.isVisible) {
        var count = this.messageCount() - this.messageCountBeforeFocusLost;
        document.title = '(' + count + ') ' + this.originalTitle;
      }
    }
  },
});

// Free sound effect from: http://www.freesoundfiles.tintagel.net/Audio/free-wave-files-beeps
PC.Room.beepHTML = '<embed src="/droplet.wav" type="audio/wav" hidden="true" autostart="true" loop="false" volume="50" />';

PC.Room.watch = function() {
  var container = $('room');
  if (container) {
    return new PC.Room(container);
  }
}