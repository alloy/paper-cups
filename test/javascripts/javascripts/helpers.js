if (typeof Test == "undefined") Test = {};

Test.Stubbing = {
  collectObservers: function() {
    Event.observers = [];
    Moksi.stub(Event, 'observe', function(element, name, handler) {
      Event.observers.push([element, name, handler]);
    });
    Moksi.stub(Event, 'stopObserving', function(element, name, handler) {
      Event.observers = Event.observers.reject(function(member) {
        return member[0] == element && member[1] == name && (!handler || member[2] == handler);
      });
    });
  },
  
  collectObserverOn: function(element) {
    Event.observers = [];
    Moksi.stub(element, 'observe', function(name, handler) {
      Event.observers.push([element, name, handler]);
    });
    Moksi.stub(element, 'stopObserving', function(name, handler) {
      Event.observers = Event.observers.reject(function(member) {
        return member[0] == element && member[1] == name && member[2] == handler;
      });
    });
  },
  
  collectAjaxRequests: function() {
    Ajax.requests = [];
    Moksi.stub(Ajax.Request.prototype, 'initialize', function(url, options) {
      Ajax.requests.push([url, options]);
    });
  },
  
  collectAjaxRequestOn: function(element) {
    Ajax.requests = [];
    Moksi.stub(element, 'request', function(options) {
      Ajax.requests.push([element, options]);
    });
  }
};

Test.Assertions = {
  doesObserverExist: function(expectedElement, expectedName) {
    return Event.observers.any(function(args) {
      return (args[0] == expectedElement) && (args[1] == expectedName);
    });
  },
  
  assertObserves: function(expectedElement, expectedName) {
    this.assertEqual(true, this.doesObserverExist(expectedElement, expectedName));
  },
  
  assertNotObserves: function(expectedElement, expectedName) {
    this.assertEqual(false, this.doesObserverExist(expectedElement, expectedName));
  },
  
  assertObserverCountOn: function(expectedElement, expectedCount) {
    this.assertEqual(expectedCount, Event.observers.inject(0, function(total, args) {
      if (args[0] == expectedElement) {
        total += 1;
      }
      return total;
    }));
  },
  
  assertRequestCount: function(expectedCount) {
    this.assertEqual(expectedCount, Ajax.requests.length);
  },
  
  assertRequestCountOn: function(expectedElement, expectedCount) {
    this.assertEqual(expectedCount, Ajax.requests.inject(0, function(total, request) {
      if (request[0] == expectedElement) {
        total += 1;
      }
      return total;
    }));
  },
  
  assertDifference: function(evalStringOrBlock, difference, block) {
    var before;
    var after;
    
    if (typeof evalStringOrBlock == 'function') {
      before = evalStringOrBlock();
      block();
      after = evalStringOrBlock();
    } else {
      before = eval(evalStringOrBlock);
      block();
      after = eval(evalStringOrBlock);
    }
    
    this.assertEqual(before + difference, after);
  },
  
  assertNoDifference: function(evalStringOrBlock, block) {
    this.assertDifference(evalStringOrBlock, 0, block);
  },
};

Test.Helpers = {
  observerHandler: function(element, name) {
    var observer = Event.observers.detect(function(args) {
      return args[0] == element && args[1] == name;
    });
    if (observer) { return observer[2]; }
  },
  
  observerHandlers: function(element, name) {
    return Event.observers.findAll(function(args) {
      return args[0] == element && args[1] == name;
    }).map(function(args) {
      return args[2];
    });
  }
};