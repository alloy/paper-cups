require File.expand_path('../test_helper', __FILE__)

class TestController
  def params
    @params ||= {}
  end
  
  def url_for(options)
    url = "/collections"
    url += "?page=#{options[:page]}" if options[:page]
    url += "?pagina=#{options[:pagina]}" if options[:pagina]
    url += "&starts_with=#{options[:starts_with]}" if options[:starts_with]
    url += "##{options[:anchor]}" if options[:anchor]
    url
  end
end

module PeijiSanHelperTestHelper
  def self.included(klass)
    klass.class_eval do
      include ActionView::Helpers
      
      attr_reader :controller
      attr_reader :collection
      
      before do
        @controller = TestController.new
        
        @collection = stub('Artists paginated collection')
        collection.stubs(:current_page?).with(1).returns(false)
        collection.stubs(:current_page?).with(2).returns(false)
        collection.stubs(:page_count).returns(125)
      end
    end
  end
end

describe "PeijiSan::ViewHelper::link_to_page" do
  include PeijiSanHelperTestHelper
  include PeijiSan::ViewHelper
  
  it "should return a link for a given page number" do
    link_to_page(2, collection).should == '<a href="/collections?page=2#explore">2</a>'
  end
  
  it "should return a link for a given page number with the specified page parameter" do
    link_to_page(2, collection, :page_parameter => 'pagina').should == '<a href="/collections?pagina=2#explore">2</a>'
  end
  
  it "should return a link for a given page number with the specified anchor" do
    link_to_page(2, collection, :anchor => 'dude_so_many_pages').should == '<a href="/collections?page=2#dude_so_many_pages">2</a>'
  end
  
  it "should return a link for a given page number and include the original params" do
    controller.params[:starts_with] = 'h'
    link_to_page(2, collection).should == '<a href="/collections?page=2&amp;starts_with=h#explore">2</a>'
  end
  
  it "should return a link which does not include the page GET variable if it's page number 1" do
    controller.params[:page] = 34
    link_to_page(1, collection).should.not.match /page=\d+/
  end
  
  it "should return a link with the class current if it's for the currently selected page" do
    collection.stubs(:current_page?).with(2).returns(true)
    link_to_page(2, collection).should == '<a href="/collections?page=2#explore" class="current">2</a>'
  end
  
  it "should return a link with the class current if it's for the currently selected page" do
    collection.stubs(:current_page?).with(2).returns(true)
    link_to_page(2, collection, :current_class => 'looking_at').should == '<a href="/collections?page=2#explore" class="looking_at">2</a>'
  end
end

describe "PeijiSan::ViewHelper::pages_to_link_to" do
  include PeijiSanHelperTestHelper
  include PeijiSan::ViewHelper
  
  it "should return a list of page numbers that should be included in the pagination list" do
    collection.stubs(:current_page).returns(83)
    pages_to_link_to(collection).should == [1, '…', 80, 81, 82, 83, 84, 85, 86, '…', 125]
  end
  
  it "should return a list of page links with an ellips between page 1 and the next if the current page is at the end of the list" do
    collection.stubs(:current_page).returns(119)
    pages_to_link_to(collection).should == [1, '…', 116, 117, 118, 119, 120, 121, 122, '…', 125]
    
    120.upto(124) do |page|
      collection.stubs(:current_page).returns(page)
      pages_to_link_to(collection).should == [1, '…', 117, 118, 119, 120, 121, 122, 123, 124, 125]
    end
  end
  
  it "should return a list of page links with an ellips between the last page and the previous one if the current page is at the beginning of the list" do
    1.upto(6) do |page|
      collection.stubs(:current_page).returns(page)
      pages_to_link_to(collection).should == [1, 2, 3, 4, 5, 6, 7, 8, 9, '…', 125]
    end
    
    collection.stubs(:current_page).returns(7)
    pages_to_link_to(collection).should == [1, '…', 4, 5, 6, 7, 8, 9, 10, '…', 125]
  end
  
  it "should not show an ellips but all pages if there are only 10 pages, this is the threshold for when an ellips starts to be necessary" do
    collection.stubs(:page_count).returns(10)
    collection.stubs(:current_page).returns(5)
    pages_to_link_to(collection).should == (1..10).to_a
  end
  
  it "should not return more page links if there aren't that many pages" do
    1.upto(9) do |page|
      collection.stubs(:page_count).returns(page)
      collection.stubs(:current_page).returns(page)
      pages_to_link_to(collection).should == (1..page).to_a
    end
  end
  
  it "should return a list of page numbers that should be included in the pagination list with the specified number of :max_visible" do
    collection.stubs(:current_page).returns(83)
    pages_to_link_to(collection, :max_visible => 5).should == [1, '…', 83, '…', 125]
    pages_to_link_to(collection, :max_visible => 15).should == [1, '…', 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, '…', 125]
    
    collection.stubs(:current_page).returns(3)
    pages_to_link_to(collection, :max_visible => 5).should == [1, 2, 3, '…', 125]
    pages_to_link_to(collection, :max_visible => 15).should == (1..13).to_a + ['…', 125]
  end
  
  it "should return a list of page numbers with the specified separator instead of the default ellips" do
    collection.stubs(:current_page).returns(83)
    pages_to_link_to(collection, :separator => '...').should == [1, '...', 80, 81, 82, 83, 84, 85, 86, '...', 125]
  end
end

module ApplicationHelperWithDefaults
  include PeijiSan::ViewHelper
  
  def peiji_san_options
    { :page_parameter => 'pagina', :anchor => 'dude_so_many_pages', :max_visible => 5, :separator => '...' }
  end
end

describe "ApplicationHelper, when overriding defaults" do
  include PeijiSanHelperTestHelper
  include ApplicationHelperWithDefaults
  
  it "should return a link for a given page number with the specified page parameter" do
    link_to_page(2, collection).should == '<a href="/collections?pagina=2#dude_so_many_pages">2</a>'
  end
  
  it "should return a link for a given page number with the specified anchor" do
    link_to_page(2, collection).should == '<a href="/collections?pagina=2#dude_so_many_pages">2</a>'
  end
  
  it "should return a link with the class current if it's for the currently selected page" do
    collection.stubs(:current_page?).with(2).returns(true)
    link_to_page(2, collection, :current_class => 'looking_at').should == '<a href="/collections?pagina=2#dude_so_many_pages" class="looking_at">2</a>'
  end
  
  it "should return a list of page numbers that should be included in the pagination list with the specified number of :max_visible" do
    collection.stubs(:current_page).returns(3)
    pages_to_link_to(collection).should == [1, 2, 3, '...', 125]
  end
  
  it "should return a list of page numbers with the specified separator instead of the default ellips" do
    collection.stubs(:current_page).returns(83)
    pages_to_link_to(collection).should == [1, '...', 83, '...', 125]
  end
end