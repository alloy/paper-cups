$shared_specs = {}

module Kernel
  # Stores the passed in block for inclusion in test cases.
  #
  #   share "User" do
  #     it "should authenticate" do
  #       "me".should == "me"
  #     end
  #   end
  #   
  #   describe "User, in general" do
  #     shared_specs_for 'User'
  #   end
  #   
  #   describe "User, in another case" do
  #     shared_specs_for 'User'
  #   end
  #
  #   2 tests, 2 assertions, 0 failures, 0 errors
  def share(name, &specs_block)
    $shared_specs[name] = specs_block
  end
end

module SharedSpecsInclusionHelper
  # Include the specified shared specs in this test case.
  #
  #   share "User" do
  #     it "should authenticate" do
  #       "me".should == "me"
  #     end
  #   end
  #   
  #   describe "User, in general" do
  #     shared_specs_for 'User'
  #   end
  #   
  #   describe "User, in another case" do
  #     shared_specs_for 'User'
  #   end
  #
  #   2 tests, 2 assertions, 0 failures, 0 errors
  def shared_specs_for(name)
    self.class_eval &$shared_specs[name]
  end
end
Test::Unit::TestCase.send(:extend, SharedSpecsInclusionHelper)