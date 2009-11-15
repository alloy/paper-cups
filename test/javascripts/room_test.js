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
      '<form id="new_message" action="/rooms/123/messages">' +
        '<textarea>foobar</textarea>' +
        '<input type="submit" />' +
      '</form>' +
      '<form>' +
        '<input type="checkbox" id="mute" />' +
      '</form>' +
    '</div>';
    
    this.form = $('new_message');
    this.textarea = this.form.down('textarea');
    
    this.collectAjaxRequests();
    this.collectObserverOn(this.form);
    this.collectObserverOn(this.textarea);
    this.collectObservers();
    
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
    Moksi.expects(this.form.down('textarea'), 'focus');
    this.room = new PC.Room.watch();
    this.room.timer.stop();
  },
  
  "should store the documents original title and that it's visible": function() {
    this.assert(this.room.isVisible);
    this.assertEqual(document.title, this.room.originalTitle);
  },
  
  "should track that the window looses focus and store the amount of exisiting messages at that moment": function() {
    observerHandler(window, 'blur')();
    this.assert(!this.room.isVisible);
    this.assertEqual(3, this.room.messageCountBeforeFocusLost);
  },
  
  "should track that the window gains focus and restores the document title": function() {
    var before = document.title;
    document.title = 'oeleboele';
    
    observerHandler(window, 'focus')();
    this.assert(this.room.isVisible);
    
    this.assertEqual(before, document.title);
  },
  
  "should return the id of the last message": function() {
    this.assertEqual('3', this.room.lastMessageId());
  },
  
  "should load the messages since the last message id, scroll down, and notify": function() {
    Moksi.expects(this.form.down('textarea'), 'scrollIntoView');
    Moksi.expects(this.room, 'notify');
    
    var request = this.loadData({
      messages: '<tr data-message-id="4"><th data-author-id="33">matt</th><td>Fourth message</td></tr>',
      online_members: '<tr><td>alloy</td></tr><tr><td>matt</td></tr>'
    });
    
    this.assertEqual('/rooms/123', request[0]);
    this.assertEqual('3', request[1].parameters.since);
    this.assertEqual('4', this.room.lastMessageId());
  },
  
  "should insert the beepHTML and show the new messages count if the window does not have focus": function() {
    var before = document.title;
    Moksi.expects(document.body, 'insert', { 'times': 2 }); // beep
    
    this.room.notify();
    this.assertEqual(before, document.title);
    
    observerHandler(window, 'blur')();
    this.room.messageCount = function() { return 9; }
    this.room.notify();
    this.assertEqual("(6) " + before, document.title);
  },
  
  "should not insert the beepHTML if the mute checkbox is checked": function() {
    $('mute').checked = true;
    Moksi.expects(document.body, 'insert', { 'times': 0 }); // no beep
    this.room.notify();
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
  
  "should create a new message through an Ajax request, stop the update timer, and disable the submit button": function() {
    Moksi.expects(this.room.timer, 'stop');
    
    observerHandler(this.form, 'submit')({ stop: function() {} });
    var request = Ajax.requests.last();
    
    this.assertEqual('/rooms/123/messages', request[0]);
    this.assertEqual('3', request[1].parameters.since);
    this.assert(this.form.down('input[type=submit]').disabled);
  },
  
  "should always re-enable the submit button, focus on the new message input, and start a new timer after trying to create a new message through Ajax": function() {
    Moksi.expects(PeriodicalExecuter.prototype, 'initialize');
    Moksi.expects(this.form.down('textarea'), 'focus');
    
    var submit = this.form.down('input[type=submit]');
    submit.disabled = true;
    observerHandler(this.form, 'submit')({ stop: function() {} });
    var request = Ajax.requests.last();
    request[1].onComplete();
    
    this.assert(!submit.disabled);
  },
  
  "should load the data when creating a new message through Ajax succeeded and clear the new message input": function() {
    var result = '';
    this.room.loadData = function(response) { result = response; };
    
    observerHandler(this.form, 'submit')({ stop: function() {} });
    var request = Ajax.requests.last();
    request[1].onSuccess('RESPONSE');
    
    this.assertEqual('RESPONSE', result);
    this.assertEqual('', this.form.down('textarea').value);
  },
  
  "should not notify if new messages arrived due to a message being created through Ajax": function() {
    Moksi.expects(document.body, 'insert', { 'times': 0 }); // no beep
    var before = document.title;
    
    this.room.loadData = function(response) {};
    observerHandler(this.form, 'submit')({ stop: function() {} });
    var request = Ajax.requests.last();
    request[1].onSuccess('');
    
    this.room.notify();
    this.assertEqual(before, document.title);
    this.assertEqual(false, this.room.dontNotify);
  },
  
  "should submit the new message if the 'enter' key is used inside the input": function() {
    var handler = observerHandler(this.textarea, 'keydown');
    var event = { keyCode: Event.KEY_RETURN };
    var result;
    this.room.submitMessage = function(e) { result = e };
    
    handler(event);
    this.assertEqual(event, result);
  },
  
  "should not submit the new message if the 'alt' and 'enter' keys are combined": function() {
    var result;
    this.room.submitMessage = function(e) { result = e };
    var handler = observerHandler(this.textarea, 'keydown');
    
    handler({ keyCode: Event.KEY_ALT });
    this.assertNull(result);
    
    handler({ keyCode: Event.KEY_RETURN });
    this.assertNull(result);
    
    var doSubmitAgain = { keyCode: Event.KEY_RETURN };
    handler(doSubmitAgain);
    this.assertEqual(doSubmitAgain, result);
  },
  
  "should submit the new message if the 'alt' key is released before using the 'enter' key": function() {
    var result;
    this.room.submitMessage = function(e) { result = e };
    var handler = observerHandler(this.textarea, 'keydown');
    
    handler({ keyCode: Event.KEY_ALT });
    this.assertNull(result);
    
    observerHandler(this.textarea, 'keyup')({ keyCode: Event.KEY_ALT });
    this.assertNull(result);
    
    var doSubmitAgain = { keyCode: Event.KEY_RETURN };
    handler(doSubmitAgain);
    this.assertEqual(doSubmitAgain, result);
  },
});