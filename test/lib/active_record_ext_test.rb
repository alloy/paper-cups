require File.expand_path('../../test_helper', __FILE__)

describe "Model that includes ActiveRecord::Ext" do
  it "should have a named scope to order" do
    Member.order('full_name').map(&:full_name).should == Member.all.map(&:full_name).sort
    Member.order('full_name', :desc).map(&:full_name).should == Member.all.map(&:full_name).sort.reverse
  end
  
  it "should have a named scope to limit" do
    Member.limit(3).should.equal_set Member.all(:limit => 3)
  end
end