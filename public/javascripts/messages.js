if (typeof CG == "undefined") CG = {};

CG.Messages = Class.create({
  initialize: function(table) {
    this.table = $(table);
    this.tbody = $(table).down('tbody');
    this.action = this.table.readAttribute('data-action');
    this.timer = new PeriodicalExecuter(this.loadMoreMessages.bindAsEventListener(this), 10);
  },
  
  lastMessageId: function() {
    return this.tbody.down('tr:last-child').readAttribute('data-message-id');
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
  },
});

CG.Messages.watch = function() {
  var table = $('messages');
  if (table) {
    return new CG.Messages(table);
  }
}