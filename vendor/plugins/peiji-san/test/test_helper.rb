module PeijiSanTest
  module Initializer
    VENDOR_RAILS = File.expand_path('../../../../rails', __FILE__)
    OTHER_RAILS = File.expand_path('../../../rails', __FILE__)
    PLUGIN_ROOT = File.expand_path('../../', __FILE__)
    
    def self.rails_directory
      if File.exist?(File.join(VENDOR_RAILS, 'railties'))
        VENDOR_RAILS
      elsif File.exist?(File.join(OTHER_RAILS, 'railties'))
        OTHER_RAILS
      end
    end
    
    def self.load_dependencies
      if rails_directory
        $:.unshift(File.join(rails_directory, 'activesupport', 'lib'))
        $:.unshift(File.join(rails_directory, 'activerecord', 'lib'))
        $:.unshift(File.join(rails_directory, 'actionpack', 'lib'))
      else
        require 'rubygems' rescue LoadError
      end
      
      require 'active_support'
      require 'active_record'
      require 'action_view'
      
      require 'rubygems' rescue LoadError
      
      require 'test/spec'
      require 'mocha'
      
      require File.join(PLUGIN_ROOT, 'rails', 'init')
    end
    
    def self.configure_database
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
      ActiveRecord::Migration.verbose = false
    end
    
    def self.setup_database
      ActiveRecord::Schema.define(:version => 1) do
        create_table :members do |t|
          t.column :name, :string
          t.column :created_at, :datetime
          t.column :updated_at, :datetime
        end
        
        create_table :works do |t|
          t.column :member_id, :integer
          t.column :status, :string
        end
      end
    end
    
    def self.teardown_database
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    end
    
    def self.start
      load_dependencies
      configure_database
    end
  end
end

PeijiSanTest::Initializer.start

class PeijiSan::PageScope
  instance_methods.each { |method| alias_method method.sub(/^has_/, 'have_'), method if method =~ /^has_/ }
  
  # The delegation of all methods in NamedScope breaks #should.
  def should
    Test::Spec::Should.new(self)
  end
end

class Member < ActiveRecord::Base
  extend PeijiSan
  self.entries_per_page = 10
  
  named_scope :all_like_krs_1, :conditions => "name LIKE 'KRS 1%'"
  named_scope :but_ending_with_9, :conditions => "name LIKE '%9'"
  
  has_many :works
end

class Work < ActiveRecord::Base
  extend PeijiSan
  self.entries_per_page = 5
  
  named_scope :uploaded, :conditions => { :status => 'uploaded' }
end