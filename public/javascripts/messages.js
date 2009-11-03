if (typeof CG == "undefined") CG = {};

CG.Messages = Class.create({
  initialize: function(table) {
    this.table = $(table);
    this.tbody = $(table).down('tbody');
    this.action = this.table.readAttribute('data-action');
    
    this.groupMessagesByAuthor();
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
    this.tbody.insert(response.responseText);
    this.groupMessagesByAuthor();
  },
  
  groupMessagesByAuthor: function() {
    var last_author;
    this.tbody.select('tr').each(function(row) {
      var author = row.down('th');
      var author_id = author.readAttribute('data-author-id');
      if (last_author && author_id == last_author) { author.innerHTML = ''; }
      last_author = author_id;
    }, this);
  },
});

CG.Messages.watch = function() {
  var table = $('messages');
  if (table) {
    return new CG.Messages(table);
  }
}