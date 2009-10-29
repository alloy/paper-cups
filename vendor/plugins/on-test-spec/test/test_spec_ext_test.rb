require File.expand_path('../test_helper', __FILE__)

module SomeIncludableAssertions
  def assert_foo
    assert true
  end
end

ActionView::TestCase.send(:include, SomeIncludableAssertions)

module SomeIncludableExpectations
  def foo
    test_case.assert_foo
  end
end

Test::Spec::Should.send(:include, SomeIncludableExpectations)

module AViewHelper
end

describe "Test::Spec::ExpectationExt, for", AViewHelper do
  it "should call assert methods directly on the test case instance" do
    lambda { Object.new.should.foo }.should.not.raise
  end
end