Test.context("PC.Room", {
  setup: function() {
    Object.extend(this, Test.Stubbing);
    Object.extend(this, Test.Assertions);
    Object.extend(this, Test.Helpers);
    
    $('sample').innerHTML = '' +
    '<div id="room" data-action="/rooms/123">' +
      '<table id="messages">' +
        '<tbody>' +
          '<tr class="message" data-message-id="1">' +
            '<th>alloy</th>' +
            '<td>First message</td>' +
          '</tr>' +
          '<tr class="message" data-message-id="2">' +
            '<th>lrz</th>' +
            '<td>Second message</td>' +
          '</tr>' +
          '<tr class="timestamp">' +
            '<th></th>' +
            '<td>11:22 AM</td>' +
          '</tr>' +
          '<tr class="message" data-message-id="3">' +
            '<th data-author-id="22">lrz</th>' +
            '<td>Third message</td>' +
          '</tr>' +
        '</tbody>' +
      '</table>' +
      '<h3 id="topic">MacRuby</h3>' +
      '<form class="edit_room" action="/rooms/123">' +
        '<input type="text" name="room[topic]" />' +
      '</form>' +
      '<table id="online_members">' +
        '<tbody>' +
          '<tr><td>alloy</td></tr>' +
        '</tbody>' +
      '</table>' +
      '<form id="new_message" action="/rooms/123/messages">' +
        '<textarea>foobar</textarea>' +
        '<input type="submit" />' +
      '</form>' +
      '<form action="/memberships/321">' +
        '<input type="checkbox" id="mute" name="mute_audio" />' +
      '</form>' +
      '<ul id="attachments">' +
          '<li><a href="/rucola-logo.gif">rucola-logo.gif</a></li>' +
          '<li><a href="/loveparade.jpg">loveparade.jpg</a></li>' +
      '</ul>' + 
    '</div>';
    
    this.form = $('new_message');
    this.textarea = this.form.down('textarea');
    
    this.collectAjaxRequests();
    this.collectObserverOn(this.form);
    this.collectObserverOn(this.textarea);
    this.collectObserverOn($('mute'));
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
  
  "should only watch a room if a data-action on the room div has been specified": function() {
    $('sample').innerHTML = $('sample').innerHTML.replace('data-action="/rooms/123"', '');
    Moksi.expects(PC.Room.prototype, 'initialize', { 'times': 0 });
    this.room = new PC.Room.watch();
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
  
  "should only count messages with class 'message'": function() {
    this.assertEqual(3, this.room.messageCount());
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
      messages: '<tr class="message" data-message-id="4"><th data-author-id="33">matt</th><td>Fourth message</td></tr>',
      online_members: '<tr><td>alloy</td></tr><tr><td>matt</td></tr>'
    });
    
    this.assertEqual('/rooms/123', request[0]);
    this.assertEqual('3', request[1].parameters.since);
    this.assertEqual('4', this.room.lastMessageId());
  },
  
  "should insert the BEEP_HTML and show the new messages count if the window does not have focus": function() {
    var before = document.title;
    Moksi.expects(document.body, 'insert', { 'times': 2 }); // beep
    
    this.room.notify();
    this.assertEqual(before, document.title);
    
    observerHandler(window, 'blur')();
    this.room.messageCount = function() { return 9; }
    this.room.notify();
    this.assertEqual("(6) " + before, document.title);
  },
  
  "should remove existing BEEP_HTML before inserting a new one, this makes Safari beep only once when tab is focussed": function() {
    this.room.notify();
    this.room.notify();
    this.room.notify();
    
    this.assertEqual(1, document.body.select('embed').length);
  },
  
  "should not insert the BEEP_HTML if the mute checkbox is checked": function() {
    $('mute').checked = true;
    Moksi.expects(document.body, 'insert', { 'times': 0 }); // no beep
    this.room.notify();
  },
  
  "should save the mute state through an Ajax request if the state changes": function() {
    var mute = $('mute');
    mute.checked = true;
    
    var handler = observerHandler(mute, 'change');
    handler({});
    
    var request = Ajax.requests.last();
    this.assertEqual('/memberships/321', request[0]);
    this.assertEqual('on', request[1].parameters['mute_audio']);
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
    var handler = observerHandler(this.textarea, 'keypress');
    var event = { keyCode: Event.KEY_RETURN, altKey: false };
    var result;
    this.room.submitMessage = function(e) { result = e };
    
    handler(event);
    this.assertEqual(event, result);
  },
  
  "should not submit the new message if the 'alt' and 'enter' keys are combined, but insert a new line": function() {
    var result;
    this.room.submitMessage = function(e) { result = e };
    var handler = observerHandler(this.textarea, 'keypress');
    
    this.textarea.selectionStart = 3;
    handler({ keyCode: Event.KEY_RETURN, altKey: true, stop: function() {} });
    this.assertNull(result);
    this.assertEqual("foo\nbar", this.textarea.value);
    this.assertEqual(4, this.textarea.selectionStart);
    
    var doSubmitAgain = { keyCode: Event.KEY_RETURN, altKey: false };
    handler(doSubmitAgain);
    this.assertEqual(doSubmitAgain, result);
  },
  
  "should hide the new topic form": function() {
    this.assert(!$$('.edit_room').first().visible());
  },
  
  "should stop the update timer, submit the new topic via an Ajax request, restart the timer and load new data": function() {
    var form = $$('.edit_room').first();
    this.room.topicEditor.enterEditMode();
    $('topic-inplaceeditor').down('input[type=text]').value = 'So fresh and so new';
    
    Moksi.expects(this.room.timer, 'stop');
    this.room.topicEditor.handleFormSubmission();
    
    var request = Ajax.requests.last();
    this.assertEqual(form.action, request[0]);
    this.assertEqual('So fresh and so new', request[1].parameters['room[topic]']);
    
  },
  
  "should start the update timer and request new data if the topic was updated": function() {
    this.room.topicEditor.enterEditMode();
    this.room.topicEditor.handleFormSubmission();
    var request = Ajax.requests.last();
    
    Moksi.expects(this.room, 'requestData');
    Moksi.expects(this.room, 'startUpdateLoop');
    request[1].onSuccess();
  },
  
  "should restart the update timer if updating the topic failed": function() {
    this.room.topicEditor.enterEditMode();
    this.room.topicEditor.handleFormSubmission();
    var request = Ajax.requests.last();
    
    Moksi.expects(this.room, 'requestData', { 'times': 0 });
    Moksi.expects(this.room, 'startUpdateLoop');
    request[1].onFailure();
  },
  
  "should update the room topic": function() {
    this.loadData({ room_topic: 'New topic!', messages: '', online_members: '' });
    this.assertEqual('New topic!', $('topic').innerHTML);
  },
  
  "should refresh the attachments list": function() {
    var before = $('attachments').innerHTML;
    var data = before + '<li><a href="/messa.jpg">messa.jpg</a></li>';
    this.loadData({ attachments: data, messages: '', online_members: '', room_topic: '' });
    this.assertEqual(data, $('attachments').innerHTML);
  },
});