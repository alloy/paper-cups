if (typeof PC == "undefined") PC = {};

PC.Room = Class.create({
  initialize: function(container) {
    this.container = $(container);
    this.action = this.container.readAttribute('data-action');
    this.messagesTable = this.container.down('#messages');
    this.messagesTBody = this.messagesTable.down('tbody');
    this.attachmentsList = $('attachments');
    
    this.start();
  },
  
  start: function() {
    this.setupWindow();
    this.setupMuteCheckbox();
    this.setupRefreshedElements();
    this.setupTopicEditor();
  },
  
  setupWindow: function() {
    this.isVisible = true;
    this.originalTitle = document.title;
    Event.observe(window, 'blur',  this.windowLoosesFocus.bindAsEventListener(this));
    Event.observe(window, 'focus', this.windowGainsFocus.bindAsEventListener(this));
    window.onbeforeunload = function(event) {
      return event.returnValue = "You’re closing a window with an active chat.";
    }
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
    Object.extend(this.newMessageInput, PC.Room.TextareaExt);
    this.newMessageInput.focus();
    
    this.newMessageInput.observe('keypress', this.keyPressOnMessageInput.bindAsEventListener(this));
    this.newMessageForm.observe('submit', this.submitMessage.bindAsEventListener(this));
    
    this.startUpdateLoop();
  },
  
  setupTopicEditor: function() {
    this.topicHeader = $('topic');
    this.topicForm = $$('form.edit_room').first();
    this.topicForm.hide();
    
    this.topicEditor = new Ajax.InPlaceEditor(this.topicHeader, this.topicForm.action, {
      okControl: false,
      cancelText: 'Cancel',
      savingText: "Saving room topic…",
      callback: function(form, value) {
        this.timer.stop();
        this.topicForm.down('input[type=text]').value = value;
        return Form.serialize(this.topicForm);
      }.bind(this),
      onFailure: function() { this.startUpdateLoop(); }.bind(this),
      ajaxOptions: {
        onSuccess: function() {
          this.requestData();
          this.startUpdateLoop();
        }.bind(this)
      },
    });
  },
  
  keyPressOnMessageInput: function(event) {
    if (event.keyCode == Event.KEY_RETURN) {
      if (event.altKey) {
        event.stop();
        this.newMessageInput.insertNewLineAtCursor();
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
    return this.messagesTBody.select('tr.message').length;
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
    this.topicHeader.innerHTML = data.room_topic;
    this.onlineMembersTBody.innerHTML = data.online_members;
    this.attachmentsList.innerHTML = data.attachments;
    if (data.messages && !data.messages.strip().empty()) {
      this.messagesTBody.insert(data.messages);
      this.newMessageInput.scrollIntoView();
      this.notify();
    }
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
  if (container && container.readAttribute('data-action')) {
    return new PC.Room(container);
  }
}

PC.Room.TextareaExt = {
  insertNewLineAtCursor: function() {
    // IE
    if (document.selection) {
      document.selection.createRange().text = "\n";
    } else {
      // Others
      var start_position = this.selectionStart;
      if (start_position || start_position == 0) {
        var end_position = this.selectionEnd;
        var first_part = this.value.substring(0, start_position);
        var last_part = this.value.substring(end_position, this.value.length);
        this.value = first_part + "\n" + last_part;
        
        this.selectionStart = start_position + 1;
        this.selectionEnd = start_position + 1;
      } else {
        this.value += "\n";
      }
    }
  }
}