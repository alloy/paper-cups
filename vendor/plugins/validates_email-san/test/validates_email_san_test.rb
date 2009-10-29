require File.expand_path('../test_helper', __FILE__)

class Member < ActiveRecord::Base
  validates_email :email
  
  def run_validation?
    false
  end
end

class ValidatesEmailTest < ActiveSupport::TestCase
  def setup
    ValidatesEmailSanTest::Initializer.setup_database
    @obj = Member.new
  end
  
  def teardown
    ValidatesEmailSanTest::Initializer.teardown_database
    Member.validates_email :email
  end
  
  test "accepts valid email addresses" do
    %w{
      sasha@example.com
      foo.bar.baz@example.com
      FOO.bar.BAZ@EXAMPLE.COM
      ML+foo@example.com
      foo@bar.example.com
      foo@in.nl
    }.each do |email|
      assert_valid_email email
    end
  end
  
  test "does not allow with missing @" do
    assert_not_valid_email 'foo.example.com'
  end
  
  test "does not allow slashes" do
    assert_not_valid_email 'foo.\@example.com'
    assert_not_valid_email 'foo\bar@example.com'
  end
  
  test "does not allow colons" do
    assert_not_valid_email 'foo.:@example.com'
    assert_not_valid_email 'foo:bar@example.com'
  end
  
  test "does not allow semi-colons" do
    assert_not_valid_email 'foo.;@example.com'
    assert_not_valid_email 'foo;bar@example.com'
  end
  
  test "does not allow parentheses" do
    assert_not_valid_email 'foo(bar@example.com'
    assert_not_valid_email 'foo)bar@example.com'
    assert_not_valid_email 'foo(bar)baz@example.com'
    assert_not_valid_email 'foo.(@example.com'
    assert_not_valid_email 'foo.)@example.com'
  end
  
  test "does not allow angle brackets" do
    assert_not_valid_email 'foo<bar@example.com'
    assert_not_valid_email 'foo>bar@example.com'
    assert_not_valid_email 'foo<bar>baz@example.com'
    assert_not_valid_email 'foo.<@example.com'
    assert_not_valid_email 'foo.>baz@example.com'
  end
  
  test "does not allow square brackets" do
    assert_not_valid_email 'foo[bar@example.com'
    assert_not_valid_email 'foo]bar@example.com'
    assert_not_valid_email 'foo[bar]baz@example.com'
    assert_not_valid_email 'foo.[@example.com'
    assert_not_valid_email 'foo.]@example.com'
  end
  
  test "does not allow consecutive dots" do
    assert_not_valid_email 'foo..bar@example.com'
  end
  
  test "does not allow first character of local part to be a dot" do
    assert_not_valid_email '.foo@example.com'
  end
  
  test "does not allow last character of local part to be a dot" do
    assert_not_valid_email 'foo.@example.com'
  end
  
  test "adds a sensible default error message" do
    @obj.email = 'foo.@example.com'; @obj.valid?
    assert_match /is not a valid email address/, @obj.errors.on(:email).to_s
  end
  
  test "allows the passing of all options allowed by validates_format_of" do
    Member.validates_email :email, :message => "dude, that's sooo not an email address", :if => :run_validation?
    @obj.email = 'foo.@example.com';
    
    def @obj.run_validation?; false; end
    @obj.valid?
    assert_no_match(/dude, that's sooo not an email address/, @obj.errors.on(:email).to_s)
    
    def @obj.run_validation?; true; end
    @obj.valid?
    assert_match /dude, that's sooo not an email address/, @obj.errors.on(:email).to_s
  end
  
  private
  
  def assert_valid_email(email)
    @obj.email = email
    @obj.valid?
    assert @obj.errors.on(:email).blank?, "Expected `#{email}' to be valid"
  end
  
  def assert_not_valid_email(email)
    @obj.email = email
    @obj.valid?
    assert !@obj.errors.on(:email).blank?, "Expected `#{email}' to NOT be valid"
  end
end