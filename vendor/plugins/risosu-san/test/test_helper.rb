module RisosuSanTest
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
      require 'action_controller'
      
      require 'rubygems' rescue LoadError
      
      require 'test/spec'
      require 'mocha'
      
      $:.unshift(File.join(PLUGIN_ROOT, 'lib'))
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

RisosuSanTest::Initializer.start

# class RisosuSan::PageScope
#   instance_methods.each { |method| alias_method method.sub(/^has_/, 'have_'), method if method =~ /^has_/ }
#   
#   # The delegation of all methods in NamedScope breaks #should.
#   def should
#     Test::Spec::Should.new(self)
#   end
# end

class Member < ActiveRecord::Base
end