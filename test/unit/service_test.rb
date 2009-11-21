require File.expand_path('../../test_helper', __FILE__)

describe "Service" do
  it "should return the service for the given name" do
    Service.find('git_hub').should.be Service::GitHub
  end
  
  it "should return `nil' if no service for the given name is found" do
    Service.find('foo_bar').should.be nil
  end
end