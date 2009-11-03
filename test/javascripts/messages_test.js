Test.context("CG.Messages", {
  setup: function() {
    Object.extend(this, Test.Stubbing);
    Object.extend(this, Test.Assertions);
    Object.extend(this, Test.Helpers);
    
    $('sample').innerHTML = '' +
    '<table id="messages" data-action="/rooms/123/messages">' +
      '<tbody>' +
        '<tr data-message-id="1">' +
          '<th data-author-id="11">alloy</th>' +
          '<td>First message</td>' +
        '</tr>' +
        '<tr data-message-id="2">' +
          '<th data-author-id="22">lrz</th>' +
          '<td>Second message</td>' +
        '</tr>' +
        '<tr data-message-id="3">' +
          '<th data-author-id="22">lrz</th>' +
          '<td>Third message</td>' +
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
    this.assertEqual('3', this.instance.lastMessageId());
  },
  
  "should load the messages since the last message id": function() {
    this.instance.loadMoreMessages();
    var request = Ajax.requests.last();
    
    this.assertEqual('/rooms/123/messages', request[0]);
    this.assertEqual('3', request[1].parameters.since);
    
    var handler = request[1]['onSuccess'];
    handler({ responseText:'<tr data-message-id="4"><th data-author-id="33">matt</th><td>Fourth message</td></tr>' });
    
    this.assertEqual('4', this.instance.lastMessageId());
  },
  
  "should group messages by author on initialization": function() {
    this.assertEqual('', $$('tr[data-message-id=3]').first().down('th').innerHTML);
  },
  
  "should group messages by author after receiving new messages": function() {
    this.instance.loadMessages({
      responseText:'<tr data-message-id="4"><th data-author-id="22">lrz</th><td>Fourth message</td></tr>' +
                   '<tr data-message-id="5"><th data-author-id="33">matt</th><td>Fifth message</td></tr>'
    });
    this.assertEqual('', $$('tr[data-message-id=4]').first().down('th').innerHTML);
  },
});