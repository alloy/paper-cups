Test.context("CG.Messages", {
  setup: function() {
    Object.extend(this, Test.Stubbing);
    Object.extend(this, Test.Assertions);
    Object.extend(this, Test.Helpers);
    
    $('sample').innerHTML = '' +
    '<table id="messages" data-action="/rooms/123/messages">' +
      '<tbody>' +
        '<tr data-message-id="1">' +
          '<th>alloy</th>' +
          '<td>First message</td>' +
        '</tr>' +
        '<tr data-message-id="2">' +
          '<th>lrz</th>' +
          '<td>Second message</td>' +
        '</tr>' +
      '</tbody>' +
    '</table>';
    
    this.collectAjaxRequests();
    
    this.instance = new CG.Messages.watch();
    this.instance.timer.stop();
  },
  
  teardown: function() {
    Moksi.assertExpectations(this);
    Moksi.revert();
  },
  
  "should return the id of the last message": function() {
    this.assertEqual('2', this.instance.lastMessageId());
  },
  
  "should load the messages since the last message id": function() {
    this.instance.loadMoreMessages();
    var request = Ajax.requests.last();
    
    this.assertEqual('/rooms/123/messages', request[0]);
    this.assertEqual('2', request[1].parameters.since);
    
    var handler = request[1]['onSuccess'];
    handler({ responseText:'<tr data-message-id="3"><th>matt</th><td>Third message</td></tr>' });
    
    this.assertEqual('3', this.instance.lastMessageId());
  },
});