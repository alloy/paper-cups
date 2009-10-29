module Test
  module Spec
    module Rails
      module Macros
        # Base class for all the proxy classes defined in the macros
        class Proxy
          attr_accessor :test_case
          
          def initialize(test_case)
            self.test_case = test_case
          end
        end
        
        # Macros define methods on the Should class if they want to be called from the test case.
        class Should < Proxy
        end
        
        # Stores expression to be evaluated later in the correct binding
        class LazyValue
          attr_accessor :value
          def initialize(value)
            self.value = value
          end
        end
        
        module ClassMethods
          # Returns an instance of the Should class, this allows you to call macros from the test
          # case is a nice way:
          #
          #   should.disallow.get :index
          def should
            Test::Spec::Rails::Macros::Should.new(self)
          end
          
          # Returns true when the passed name is a known table, we assume known tables also have fixtures
          def known_fixture?(name)
            respond_to?(:fixture_table_names) && fixture_table_names.include?(name.to_s)
          end
          
          # Filter calls to fixture methods so we can use them in the definitions
          def method_missing(method, *arguments, &block)
            if known_fixture?(method)
              arguments = arguments.map { |a| a.inspect }
              Test::Spec::Rails::Macros::LazyValue.new("#{method}(#{arguments.join(', ')})")
            else
              super
            end
          end
        end
        
        module InstanceMethods
          # Interpret the non-immediate values in params and replace them
          def immediate_values(params)
            result = {}
            params.each do |key, value|
              result[key] = case value
              when Hash
                immediate_values(value)
              when Test::Spec::Rails::Macros::LazyValue
                eval(value.value).to_param
              when Proc
                value.call
              else
                value
              end
            end
            result
          end
        end
      end
    end
  end
end

Test::Spec::TestCase::ClassMethods.send(:include,    Test::Spec::Rails::Macros::ClassMethods)
Test::Spec::TestCase::InstanceMethods.send(:include, Test::Spec::Rails::Macros::InstanceMethods)

require 'test/spec/rails/macros/authorization'