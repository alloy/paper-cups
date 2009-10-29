require 'test/spec'

require 'active_support/test_case'

require 'active_record'
require 'active_record/test_case'

require 'action_controller'
require 'action_controller/test_case'

require 'action_view'
require 'action_view/test_case'

%w(test_spec_ext spec_responder expectations).each { |lib| require "test/spec/rails/#{lib}" }
Dir[File.dirname(__FILE__) + '/rails/**/*_helpers.rb'].each { |lib| require lib }

module Test
  module Spec
    module Rails
      def self.extract_test_case_args(args)
        name          = args.map { |a| a.to_s }.join(' ')
        class_to_test = args.find { |a| a.is_a?(Module) }
        superclass    = test_case_for_class(class_to_test)
        [name, class_to_test, superclass]
      end
      
      def self.test_case_for_class(klass)
        if klass
          if klass.ancestors.include?(ActiveRecord::Base)
            ActiveRecord::TestCase
          elsif klass.ancestors.include?(ActionController::Base)
            ActionController::TestCase
          elsif !klass.is_a?(Class) && klass.to_s.ends_with?('Helper')
            ActionView::TestCase
          end
        end || ActiveSupport::TestCase
      end
    end
  end
end

module Kernel
  alias :context_before_on_test_spec :context
  alias :xcontext_before_on_test_spec :xcontext
  
  # Creates a new test case.
  #
  # The description of the test case, can consist from strings and/or the class
  # that's to be tested.
  #
  # If the class inherits from ActiveRecord::Base, ActiveRecord::TestCase will
  # be used as the test case superclass. In the case of a class which inherits
  # from ActionController::Base, ActionController::TestCase will be used. And
  # when given a module which name ends with “Helper”, ActionView::TestCase
  # will be used. In the latter two cases, the test case will be setup for the
  # class that's to be tested.
  #
  # In all other cases the test case superclass will be ActiveSupport::TestCase.
  #
  # Examples:
  #
  #   describe Member do # "Member"
  #     ...
  #   end
  #
  #   describe 'On a', MembersController do # "On a MembersController"
  #     ...
  #   end
  #
  #   describe 'The', MembersHelper, ', concerning dates' do # "The MembersHelper, concerning dates"
  #     ...
  #   end
  def context(*args, &block)
    name, class_to_test, superclass = Test::Spec::Rails.extract_test_case_args(args)
    spec = context_before_on_test_spec(name, superclass) { tests class_to_test if respond_to?(:tests) }
    spec.testcase.class_eval(&block)
    spec
  end
  
  def xcontext(*args, &block)
    name, _, superclass = Test::Spec::Rails.extract_test_case_args(args)
    xcontext_before_on_test_spec(name, superclass, &block)
  end
  
  private :context, :xcontext
  
  alias :describe :context
  alias :xdescribe :xcontext
end