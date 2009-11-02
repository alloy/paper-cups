var Moksi = {
  stubbed: [],
  called: {},
  expected: {},
  
  beforeStubPrefix: "__before_stub_",
  beforeStubRegexp: /^__before_stub_(.*)$/,

  stubbedFunctionName: function(functionName) {
    return this.beforeStubPrefix + functionName;
  },
  
  stub: function(object, functionName, definition) {
    var temporaryName = this.stubbedFunctionName(functionName);
    
    object[temporaryName] = object[functionName];
    object[functionName] = definition;
    
    if (this.stubbed.indexOf(object) == -1) {
      this.stubbed.push(object);
    }
  },
  
  unstub: function(object, functionName) {
    var temporaryName = this.stubbedFunctionName(functionName);
    this.revertMethod(object, functionName, temporaryName);
  },
  
  expects: function(object, functionName, options) {
    options = options || {};
    if (options.times == undefined) options.times = 1;
    
    this.expected[object] = this.expected[object] || {}
    this.expected[object][functionName] = [];
    this.expected[object][functionName].push(options);
    
    this.stub(object, functionName, function() {
      Moksi.called[object] = Moksi.called[object] || {};
      Moksi.called[object][functionName] = Moksi.called[object][functionName] || [];
      Moksi.called[object][functionName].push(this[functionName].arguments);
    });
  },
  
  rejects: function(object, functionName) {
    this.expects(object, functionName, {times: 0});
  },
  
  revert: function() {
    var object;
    while(object = this.stubbed.pop()) {
      for (var property in object) {
        var match;
        if (match = property.match(this.beforeStubRegexp)) {
          this.revertMethod(object, match[1], property);
        }
      }
    }
    this.expected = {};
    this.called = {};
  },
  
  revertMethod: function(object, originalName, temporaryName) {
    object[originalName] = object[temporaryName];
    delete object[temporaryName];
  },
  
  sameObject: function(left, right) {
    if (typeof left == 'object' && typeof right == 'object') {
      for (var key in left) { if (left.hasOwnProperty(key)) {
        if (!this.sameObject(left[key], right[key])) return false;
      }}
      for (var key in right) { if (right.hasOwnProperty(key)) {
        if (!this.sameObject(left[key], right[key])) return false;
      }}
      return true;
    } else {
      return left == right;
    }
  },
  
  sameArguments: function(left, right) {
    if (left.length != right.length) return false;
    
    for(i=0; i < left.length; i++) {
      if (!this.sameObject(left[i], right[i])) return false;
    }
    return true;
  },
  
  assertExpectation: function(testCase, object, functionName, expected) {
    var callsToFunction = [];
    if (this.called[object] && this.called[object][property]) {
      callsToFunction = this.called[object][property];
    }
    
    var timesCalled = 0;
    for (var i = 0; i < callsToFunction.length; i++) {
      if (typeof expected['with'] == 'undefined' || this.sameArguments(callsToFunction[i], expected['with'])) {
        timesCalled++;
      }
    }
    
    var name;
    if (typeof object.name == "undefined") { name = 'Object' } else { name = object.name };
    var message = 'expected ' + name + '.' + property + ' to be called ' +
      expected.times + ' times, but was called ' + timesCalled + ' times';
    testCase.assertEqual(expected.times, timesCalled, message);
  },
  
  assertExpectations: function(testCase) {
    for (object in this.expected) { if (this.expected.hasOwnProperty(object)) {
      for (property in this.expected[object]) { if (this.expected[object].hasOwnProperty(property)) {
        for (expected in this.expected[object][property]) { if (this.expected[object][property].hasOwnProperty(expected)) {
          this.assertExpectation(testCase, object, property, this.expected[object][property][expected]);
        }}
      }}
    }}
  }
};