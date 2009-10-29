require File.expand_path('../test_helper', __FILE__)
require 'test/spec/rails'

module TestingAssertionsThemselves
  class << self
    def setup
      $TEST_SPEC_TESTCASE = TestingAssertionsThemselves
      TestingAssertionsThemselves.assertions = []
    end
    
    attr_accessor :assertions
    
    def assert(*args)
      TestingAssertionsThemselves.assertions << [:assert, args]
    end
    
    def assert_equal(*args)
      TestingAssertionsThemselves.assertions << [:assert_equal, args]
    end
    
    def last_assertion
      TestingAssertionsThemselves.assertions.last
    end
  end
end

module AssertionAssertions
  def assert_assert_success(message=nil)
    assertion = TestingAssertionsThemselves.last_assertion
    
    assert_equal :assert, assertion[0]
    assert assertion[1][0]
    assert_equal(message, assertion[2][1]) if message
  end
  
  def assert_assert_failure(message=nil)
    assertion = TestingAssertionsThemselves.last_assertion
    
    assert_equal :assert, assertion[0]
    assert !assertion[1][0]
    assert_equal(message, assertion[1][1]) if message
  end
  
  def assert_assert_equal_success(message=nil)
    assertion = TestingAssertionsThemselves.last_assertion
    
    assert_equal :assert_equal, assertion[0]
    assert_equal assertion[1][0], assertion[1][1]
    assert_equal(message, assertion[1][2]) if message
  end
  
  def assert_assert_equal_failure(message=nil)
    assertion = TestingAssertionsThemselves.last_assertion
    
    assert_equal :assert_equal, assertion[0]
    assert_not_equal assertion[1][0], assertion[1][1]
    assert_equal(message, assertion[1][2]) if message
  end
end

class Pony
  class << self
    attr_accessor :count
  end
end

describe "Differ expectations" do
  include AssertionAssertions
  attr_accessor :controller
  
  before do
    TestingAssertionsThemselves.setup
  end
  
  it "should succeed when the expected difference occurs on a local variable" do
    count = 1
    lambda {
      count = 2
    }.should.differ('count')
    assert_assert_equal_success
  end
  
  it "should succeed when the expected difference occurs on an instance variable in the current scope" do
    @count = 1
    lambda {
      @count = 2
    }.should.differ('@count')
    assert_assert_equal_success
  end
  
  it "should succeed when the expected difference occurs on a class in the current scope" do
    Pony.count = 1
    lambda {
      Pony.count = 2
    }.should.differ('Pony.count')
    assert_assert_equal_success
  end
  
  it "should succeed when the difference is explicitly stated" do
    Pony.count = 1
    lambda {
      Pony.count = 3
    }.should.differ('Pony.count', +2)
    assert_assert_equal_success
  end
  
  it "should fail when the expected difference does not occur" do
    Pony.count = 1
    lambda {
      Pony.count = 3
    }.should.differ('Pony.count')
    assert_assert_equal_failure('"Pony.count" didn\'t change by 1')
  end
  
  it "should fail when the explicitly stated difference does not occur" do
    Pony.count = 1
    lambda {
      Pony.count = 3
    }.should.differ('Pony.count', +5)
    assert_assert_equal_failure('"Pony.count" didn\'t change by 5')
  end
  
  it "should return the return value of the block" do
    Pony.count = 3
    result = lambda {
      Pony.count += 1
    }.should.differ('Pony.count', 1)
    assert_equal 4, result, "differ didn't return the block result"
  end
  
  it "should succeed when multiple expected differences occur" do
    count = 1
    Pony.count = 1
    lambda {
      count = 2
      Pony.count = 2
    }.should.differ('Pony.count', +1, 'count', +1)
    
    TestingAssertionsThemselves.assertions.each do |assertion, args|
      assert_equal :assert_equal, assertion
      assert_equal args[0], args[1]
    end
  end
  
  it "should fail when first of the expected differences does not occur" do
    count = 1
    Pony.count = 1
    lambda {
      count += 4
    }.should.differ('Pony.count', +2, 'count', +4)
    
    assertion, args = TestingAssertionsThemselves.assertions.first
    assert_equal :assert_equal, assertion
    assert_not_equal(args[0], args[1])
    assert_equal '"Pony.count" didn\'t change by 2', args[2]
    
    assertion, args = TestingAssertionsThemselves.assertions.second
    assert_equal :assert_equal, assertion
    assert_equal(args[0], args[1])
  end
  
  it "should fail when second of the expected differences does not occur" do
    count = 1
    Pony.count = 1
    lambda {
      Pony.count += 2
    }.should.differ('Pony.count', +2, 'count', +4)
    
    assertion, args = TestingAssertionsThemselves.assertions.first
    assert_equal :assert_equal, assertion
    assert_equal(args[0], args[1])
    
    assertion, args = TestingAssertionsThemselves.assertions.second
    assert_equal :assert_equal, assertion
    assert_not_equal(args[0], args[1])
    assert_equal '"count" didn\'t change by 4', args[2]
  end
end

describe "NotDiffer expectations" do
  include AssertionAssertions
  attr_accessor :controller
  
  before do
    TestingAssertionsThemselves.setup
  end
  
  it "should succeed when no difference occurs on a local variable" do
    count = 1
    lambda {
    }.should.not.differ('count')
    assert_assert_equal_success
  end
  
  it "should succeed when no difference occurs on an instance variable in the current scope" do
    @count = 1
    lambda {
    }.should.not.differ('@count')
    assert_assert_equal_success
  end
  
  it "should succeed when no difference occurs on a class in the current scope" do
    Pony.count = 1
    lambda {
    }.should.not.differ('Pony.count')
    assert_assert_equal_success
  end
  
  it "should fail when a difference occurs" do
    Pony.count = 1
    lambda {
      Pony.count = 3
    }.should.not.differ('Pony.count')
    assert_assert_equal_failure('"Pony.count" changed by 2, expected no change')
  end
  
  it "should return the return value of the block" do
    Pony.count = 3
    result = lambda {
      Pony.count += 1
    }.should.not.differ('Pony.count')
    assert_equal 4, result, "differ didn't return the block result"
  end
  
  it "should succeed when multiple expected differences do not occur" do
    count = 1
    Pony.count = 1
    lambda {
    }.should.not.differ('Pony.count', 'count')
    
    TestingAssertionsThemselves.assertions.each do |assertion, args|
      assert_equal :assert_equal, assertion
      assert_equal args[0], args[1]
    end
  end
  
  it "should fail when first of the expected differences does occur" do
    count = 1
    Pony.count = 1
    lambda {
      Pony.count += 2
    }.should.not.differ('Pony.count', 'count')
    
    assertion, args = TestingAssertionsThemselves.assertions.first
    assert_equal :assert_equal, assertion
    assert_not_equal(args[0], args[1])
    assert_equal '"Pony.count" changed by 2, expected no change', args[2]
    
    assertion, args = TestingAssertionsThemselves.assertions.second
    assert_equal :assert_equal, assertion
    assert_equal(args[0], args[1])
  end
  
  it "should fail when second of the expected differences does occur" do
    count = 1
    Pony.count = 1
    lambda {
      count += 4
    }.should.not.differ('Pony.count', 'count')
    
    assertion, args = TestingAssertionsThemselves.assertions.first
    assert_equal :assert_equal, assertion
    assert_equal(args[0], args[1])
    
    assertion, args = TestingAssertionsThemselves.assertions.second
    assert_equal :assert_equal, assertion
    assert_not_equal(args[0], args[1])
    assert_equal '"count" changed by 4, expected no change', args[2]
  end
end


describe "Record expectations" do
  include AssertionAssertions
  attr_accessor :controller
  
  before do
    TestingAssertionsThemselves.setup
  end
  
  it "should succeed when equal_set assertions are correct" do
    [].should.equal_set []
    assert_assert_success
    
    [stub(:id => 1)].should.equal_set [stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1), stub(:id => 1)].should.equal_set [stub(:id => 1), stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1), stub(:id => 2)].should.equal_set [stub(:id => 1), stub(:id => 2)]
    assert_assert_success
    
    [stub(:id => 2)].should.not.equal_set [stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1), stub(:id => 2)].should.not.equal_set [stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1)].should.not.equal_set [stub(:id => 1), stub(:id => 2)]
    assert_assert_success

    # equal_set ignores order
    [stub(:id => 1), stub(:id => 2)].should.equal_set [stub(:id => 2), stub(:id => 1)]
    assert_assert_success
  end
  
  it "should fail when equal_set assertions are not correct" do
    [].should.not.equal_set []
    assert_assert_failure("[] has the same records as []")
    
    [stub(:id => 1), stub(:id => 1)].should.equal_set [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[1]] does not have the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1), stub(:id => 2)].should.equal_set [stub(:id => 1), stub(:id => 1), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] does not have the same records as [Mocha::Mock[1], Mocha::Mock[1], Mocha::Mock[2]]")
    
    [stub(:id => 1), stub(:id => 2), stub(:id => 1)].should.equal_set [stub(:id => 1), stub(:id => 2), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2], Mocha::Mock[1]] does not have the same records as [Mocha::Mock[1], Mocha::Mock[2], Mocha::Mock[2]]")
    
    [stub(:id => 1)].should.not.equal_set [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1]] has the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1), stub(:id => 2)].should.not.equal_set [stub(:id => 1), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] has the same records as [Mocha::Mock[1], Mocha::Mock[2]]")
    
    [stub(:id => 2)].should.equal_set [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[2]] does not have the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1), stub(:id => 2)].should.equal_set [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] does not have the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1)].should.equal_set [stub(:id => 1), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1]] does not have the same records as [Mocha::Mock[1], Mocha::Mock[2]]")
  end

  it "should succeed when equal_list assertions are correct" do
    [].should.equal_list []
    assert_assert_success
    
    [stub(:id => 1)].should.equal_list [stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1), stub(:id => 1)].should.equal_list [stub(:id => 1), stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1), stub(:id => 2)].should.equal_list [stub(:id => 1), stub(:id => 2)]
    assert_assert_success
    
    [stub(:id => 2)].should.not.equal_list [stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1), stub(:id => 2)].should.not.equal_list [stub(:id => 1)]
    assert_assert_success
    
    [stub(:id => 1)].should.not.equal_list [stub(:id => 1), stub(:id => 2)]
    assert_assert_success

    # equal_list does not ignore order
    [stub(:id => 1), stub(:id => 2)].should.not.equal_list [stub(:id => 2), stub(:id => 1)]
    assert_assert_success
  end
  
  it "should fail when equal_list assertions are not correct" do
    [].should.not.equal_list []
    assert_assert_failure("[] has the same records as []")
    
    [stub(:id => 1), stub(:id => 1)].should.equal_list [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[1]] does not have the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1), stub(:id => 2)].should.equal_list [stub(:id => 1), stub(:id => 1), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] does not have the same records as [Mocha::Mock[1], Mocha::Mock[1], Mocha::Mock[2]]")
    
    [stub(:id => 1), stub(:id => 2), stub(:id => 1)].should.equal_list [stub(:id => 1), stub(:id => 2), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2], Mocha::Mock[1]] does not have the same records as [Mocha::Mock[1], Mocha::Mock[2], Mocha::Mock[2]]")
    
    [stub(:id => 1)].should.not.equal_list [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1]] has the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1), stub(:id => 2)].should.not.equal_list [stub(:id => 1), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] has the same records as [Mocha::Mock[1], Mocha::Mock[2]]")
    
    [stub(:id => 2)].should.equal_list [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[2]] does not have the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1), stub(:id => 2)].should.equal_list [stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] does not have the same records as [Mocha::Mock[1]]")
    
    [stub(:id => 1)].should.equal_list [stub(:id => 1), stub(:id => 2)]
    assert_assert_failure("[Mocha::Mock[1]] does not have the same records as [Mocha::Mock[1], Mocha::Mock[2]]")
    
    # equal_list does not ignore order
    [stub(:id => 1), stub(:id => 2)].should.equal_list [stub(:id => 2), stub(:id => 1)]
    assert_assert_failure("[Mocha::Mock[1], Mocha::Mock[2]] does not have the same records as [Mocha::Mock[2], Mocha::Mock[1]]")
  end
end

class TestController
  def request
    unless @request
      @request ||= Object.new
      def @request.env
        @env ||= {}
      end
    end
    @request
  end
end

describe "Redirection expectations" do
  include AssertionAssertions
  attr_accessor :controller
  
  before do
    TestingAssertionsThemselves.setup
    
    @controller = TestController.new
    @controller.stubs(:url_for).returns(@url)
    
    @matcher = stub('matcher')
    self.stubs(:should).returns(@matcher)
    @matcher.stubs(:redirect_to)
    
    @url = 'new_session_url'
  end
  
  it "should set the request env HTTP_REFERER before executing the proc" do
    @controller.expects(:url_for).with(@url).returns(@url)
    lambda {}.should.redirect_back_to(@url)
    assert_equal @url, controller.request.env['HTTP_REFERER']
  end
  
  it "should call the `redirect_to' matcher with the url _after_ executing the proc" do
    def @matcher.redirect_to(*args)
      raise "Oh noes, should not be called yet!"
    end
    
    lambda {
      def @matcher.redirect_to(*args)
        @called = true
      end
    }.should.redirect_back_to(@url)
    
    assert @matcher.instance_variable_get(:@called)
  end
  
  it "should work with regular url options as well" do
    @controller.expects(:url_for).with(:action => :new).returns(@url)
    @matcher.expects(:redirect_to).with(@url)
    
    lambda {}.should.redirect_back_to(:action => :new)
    assert_equal @url, controller.request.env['HTTP_REFERER']
  end
  
  it "should return the result of calling the block" do
    result = lambda { "called block" }.should.redirect_back_to(@url)
    assert_equal "called block", result
  end
end
