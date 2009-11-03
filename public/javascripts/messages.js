if (typeof CG == "undefined") CG = {};

CG.Messages = Class.create({
  initialize: function(table) {
    this.table = $(table);
    this.tbody = $(table).down('tbody');
    this.action = this.table.readAttribute('data-action');
    this.timer = new PeriodicalExecuter(this.loadMoreMessages.bindAsEventListener(this), 10);
  },
  
  lastMessage: function() {
    return this.tbody.down('tr:last-child');
  },
  
  lastMessageId: function() {
    return this.lastMessage().readAttribute('data-message-id');
  },
  
  loadMoreMessages: function() {
    new Ajax.Request(this.action, {
      method: 'get',
      parameters: { since: this.lastMessageId() },
      onSuccess: this.loadMessages.bindAsEventListener(this),
    });
  },
  
  loadMessages: function(response) {
    var last = this.lastMessage();
    this.tbody.insert(response.responseText);
    
    var author = last.nextSibling.down('th');
    if (author.readAttribute('data-author-id') == last.down('th').readAttribute('data-author-id')) {
      author.innerHTML = '';
    }
  },
});

CG.Messages.watch = function() {
  var table = $('messages');
  if (table) {
    return new CG.Messages(table);
  }
}