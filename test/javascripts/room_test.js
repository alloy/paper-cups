Test.context("PC.Room", {
  setup: function() {
    Object.extend(this, Test.Stubbing);
    Object.extend(this, Test.Assertions);
    Object.extend(this, Test.Helpers);
    
    $('sample').innerHTML = '' +
    '<div id="room" data-action="/rooms/123">' +
      '<table id="messages">' +
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
      '</table>' +
      '<table id="online_members">' +
        '<tbody>' +
          '<tr><td>alloy</td></tr>' +
        '</tbody>' +
      '</table>' +
      '<form id="new_message">' +
        '<textarea></textarea>' +
      '</form>'
    '</div>';
    
    this.collectAjaxRequests();
    
    this.loadData = function(data) {
      this.room.requestData();
      var request = Ajax.requests.last();
      var handler = request[1]['onSuccess'];
      handler({ responseText: Object.toJSON(data) });
      return request;
    }.bind(this);
    
    this.room = new PC.Room.watch();
    this.room.timer.stop();
  },
  
  teardown: function() {
    Moksi.assertExpectations(this);
    Moksi.revert();
  },
  
  "should set focus to the new message textarea": function() {
    Moksi.expects($('new_message').down('textarea'), 'focus');
    this.room = new PC.Room.watch();
    this.room.timer.stop();
  },
  
  "should return the id of the last message": function() {
    this.assertEqual('3', this.room.lastMessageId());
  },
  
  "should load the messages since the last message id": function() {
    var request = this.loadData({
      messages: '<tr data-message-id="4"><th data-author-id="33">matt</th><td>Fourth message</td></tr>',
      online_members: '<tr><td>alloy</td></tr><tr><td>matt</td></tr>'
    });
    
    this.assertEqual('/rooms/123', request[0]);
    this.assertEqual('3', request[1].parameters.since);
    this.assertEqual('4', this.room.lastMessageId());
  },
  
  "should group messages by author on initialization": function() {
    this.assertEqual('', $$('tr[data-message-id=3]').first().down('th').innerHTML);
  },
  
  "should group messages by author after receiving new messages": function() {
    this.loadData({
      messages: '<tr data-message-id="4"><th data-author-id="22">lrz</th><td>Fourth message</td></tr>' +
                '<tr data-message-id="5"><th data-author-id="33">matt</th><td>Fifth message</td></tr>',
      online_members: ''
    });
    this.assertEqual('', $$('tr[data-message-id=4]').first().down('th').innerHTML);
  },
  
  "should not group messages by author if no new messages were added": function() {
    Moksi.expects(this.room, 'groupMessagesByAuthor', { times: 0 });
    this.loadData({ messages: "\n  \n", online_members: '' });
    this.loadData({ messages: null, online_members: '' });
  },
  
  "should update the online members table with the result": function() {
    this.loadData({ messages: '', online_members: '<tr><td>lrz</td></tr><tr><td>matt</td></tr>' });
    var members = $$('#online_members tr td');
    
    this.assertEqual(2, members.length);
    this.assertEqual('lrz', members[0].innerHTML);
    this.assertEqual('matt', members[1].innerHTML);
    
    this.loadData({ messages: '', online_members: '' });
    this.assertEqual(0, $$('#online_members tr td').length);
  },
});