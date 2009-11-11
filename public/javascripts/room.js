if (typeof PC == "undefined") PC = {};

PC.Room = Class.create({
  initialize: function(container) {
    this.container = $(container);
    this.messagesTable = this.container.down('#messages');
    this.messagesTBody = this.messagesTable.down('tbody');
    this.newMessageInput = $('new_message').down('textarea');
    this.onlineMembersTBody = this.container.down('#online_members');
    this.action = this.container.readAttribute('data-action');
    
    this.start();
    this.timer = new PeriodicalExecuter(this.requestData.bindAsEventListener(this), 10);
  },
  
  start: function() {
    this.newMessageInput.focus();
    this.groupMessagesByAuthor();
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
  
  loadData: function(response) {
    var data = response.responseText.evalJSON();
    this.onlineMembersTBody.innerHTML = data.online_members;
    if (data.messages && !data.messages.strip().empty()) {
      this.messagesTBody.insert(data.messages);
      this.groupMessagesByAuthor();
      this.newMessageInput.scrollIntoView();
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
});

PC.Room.watch = function() {
  var container = $('room');
  if (container) {
    return new PC.Room(container);
  }
}