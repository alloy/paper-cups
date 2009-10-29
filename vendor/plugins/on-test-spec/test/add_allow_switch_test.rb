require File.expand_path('../test_helper', __FILE__)
require 'test/spec/add_allow_switch'

module Factory
  def self.run
    true
  end
end
Factory.add_allow_switch :run, :default => true

describe "Factory with an allow switch on run" do
  it "should alias the original method" do
    Factory.respond_to?(:original_run, include_private=true).should == true
  end
  
  it "should define a getter and setter" do
    Factory.should.respond_to(:allow_run)
    Factory.should.respond_to(:allow_run=)
  end
  
  it "should switch off" do
    Factory.allow_run = false
    lambda {
      Factory.run
    }.should.raise(RuntimeError)
  end
  
  it "should switch on" do
    Factory.allow_run = true
    lambda {
      Factory.run.should == true
    }.should.not.raise
  end
end

class Bunny
  def hop
    'Hop hop!'
  end
end
Bunny.add_allow_switch :hop

describe "Bunny with an allow switch on hop" do
  before do
    @bunny = Bunny.new
  end
  
  it "should alias the original method" do
    @bunny.respond_to?(:original_hop).should == true
  end
  
  it "should define a getter and setter" do
    Bunny.should.respond_to(:allow_hop)
    Bunny.should.respond_to(:allow_hop=)
  end
  
  it "should switch off" do
    Bunny.allow_hop = false
    lambda {
      @bunny.hop
    }.should.raise(RuntimeError)
  end
  
  it "should switch on" do
    Bunny.allow_hop = true
    lambda {
      @bunny.hop.should == 'Hop hop!'
    }.should.not.raise
  end
end


Kernel.add_allow_switch :system

describe "Kernel with an allow switch on system" do
  SILENT_COMMANT = 'ls > /dev/null'
  
  it "should alias the original method" do
    Kernel.respond_to?(:original_system, include_private=true).should == true
  end
  
  it "should define a getter and setter" do
    Factory.should.respond_to(:allow_system)
    Factory.should.respond_to(:allow_system=)
  end
  
  it "should switch off" do
    Kernel.allow_system = false
    lambda {
      Kernel.system(SILENT_COMMANT)
    }.should.raise(RuntimeError)
  end
  
  it "should switch on" do
    Kernel.allow_system = true
    lambda {
      Kernel.system(SILENT_COMMANT)
    }.should.not.raise
  end
end