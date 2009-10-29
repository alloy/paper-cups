require File.expand_path('../test_helper', __FILE__)

describe "PeijiSan mixin" do
  it "should define an #entries_per_page= class method with which the max amount of entries per page is specified" do
    Member.should.respond_to :entries_per_page=
    Member.instance_variable_get(:@entries_per_page).should.be 10
  end
  
  it "should define an #entries_per_page reader method" do
    Member.entries_per_page.should == 10
  end
  
  it "should have defined a #page class method and added it to the class's scopes" do
    Member.should.respond_to :page
  end
end

describe "PeijiSan::PageScope" do
  before do
    PeijiSanTest::Initializer.setup_database
    199.times { |i| Member.create(:name => "KRS #{i}") }
  end
  
  after do
    PeijiSanTest::Initializer.teardown_database
  end
  
  it "should have defined a named_scope called :page which returns the entries belonging to the page number given" do
    page_1 = Member.page(1)
    page_1.class.should.be PeijiSan::PageScope
    page_1.length.should.be 10
    page_1.should == Member.find(:all, :offset => 0, :limit => 10)
  end
  
  it "should return the correct count of pages for the current scope" do
    Member.all_like_krs_1.page(1).page_count.should.be 11
  end
  
  it "should know the current page number" do
    Member.page(2).current_page.should.be 2
    Member.page(4).current_page.should.be 4
  end
  
  it "should know if there's a next page" do
    Member.page(1).should.have_next_page
    Member.page(20).should.not.have_next_page
    Member.all_like_krs_1.but_ending_with_9.page(1).should.not.have_next_page
  end
  
  it "should return the next page" do
    Member.page(1).next_page.should.be 2
    Member.page(20).next_page.should.be nil
  end
  
  it "should know if there's a previous page" do
    Member.page(1).should.not.have_previous_page
    Member.page(20).should.have_previous_page
  end
  
  it "should return the previous page" do
    Member.page(1).previous_page.should.be nil
    Member.page(20).previous_page.should.be 19
  end
  
  it "should return if a given page number is the current page" do
    assert Member.page(1).current_page?(1)
    assert !Member.page(1).current_page?(2)
  end
  
  it "should default to page 1 if no valid page argument was given" do
    Member.page(nil).current_page.should.be 1
    Member.page('').current_page.should.be 1
  end
  
  it "should cast the page argument to an integer" do
    Member.page('2').current_page.should.be 2
  end
  
  it "should take an optional second argument which overrides the entries_per_page setting" do
    Member.all_like_krs_1.page(1, 20).page_count.should.be 6
  end
  
  it "should return the count of all the entries across all pages for the current scope" do
    Member.all_like_krs_1.page(1).count.should.be 110
    Member.all_like_krs_1.page(2).count.should.be 110
    Member.all_like_krs_1.but_ending_with_9.page(1).count.should.be 10
  end
  
  it "should still work when chained with other regular named scopes" do
    Member.all_like_krs_1.page(1).page_count.should.be 11
    Member.all_like_krs_1.but_ending_with_9.page(2).page_count.should.be 1
    
    Member.all_like_krs_1.page(2).should == Member.find(:all, :conditions => "name LIKE 'KRS 1%'", :offset => 10, :limit => 10)
    Member.all_like_krs_1.but_ending_with_9.page(1).should == Member.find(:all, :conditions => "name LIKE 'KRS 1%' AND name LIKE '%9'", :offset => 0, :limit => 10)
  end
  
  it "should still work when chained through an association proxy" do
    member = Member.first
    16.times { member.works.create(:status => 'uploaded') }
    5.times { member.works.create(:status => 'new') }
    
    page = member.reload.works.uploaded.page(1)
    page.length.should.be 5
    page.page_count.should.be 4
    member.works.uploaded.page(4).length.should.be 1
    
    member.works.page(1).page_count.should.be 5
  end
end