module Test
  module Spec
    module Rails
      module Macros
        class Should
          # Generates a test which tests authorization code. It assumes a method called <code>access_denied?</code>
          # on the test case. The <code>access_denied?</code> method should return true when access is denied
          # (ie. a 403 status code) and false in other cases.
          #
          # Example:
          #   should.disallow.get :index
          def disallow
            Test::Spec::Rails::Macros::Authorization::TestGenerator.new(test_case,
              :access_denied?, true,
              'Expected access to be denied'
            )
          end
          
          # Generates a test which tests authorization code. It assumes a method called <code>access_denied?</code>
          # on the test case. The <code>access_denied?</code> method should return true when access is denied
          # (ie. a 403 status code) and false in other cases.
          #
          # Example:
          #   should.allow.get :index
          def allow
            Test::Spec::Rails::Macros::Authorization::TestGenerator.new(test_case,
              :access_denied?, false,
              'Expected access to be allowed'
            )
          end
          
          # Generates a test which tests authorization code. It assumes a method called <code>access_denied?</code>
          # on the test case. The <code>login_required?</code> method should return true when the visitor was
          # asked for credentials (ie. a 401 status code or a redirect to a login page) and false in other cases.
          #
          # Example:
          #   should.require_login.get :index
          def require_login
            Test::Spec::Rails::Macros::Authorization::TestGenerator.new(test_case,
              :login_required?, true,
              'Expected login to be required'
            )
          end
        end
        
        module Authorization
          class TestGenerator < Proxy
            attr_accessor :validation_method, :message, :expected
            
            def initialize(test_case, validation_method, expected, message)
              self.validation_method = validation_method
              self.expected = expected
              self.message = message
              
              super(test_case)
            end
            
            def method_missing(verb, action, params={})
              if [:get, :post, :put, :delete, :options].include?(verb.to_sym)
                description = "should disallow #{verb.to_s.upcase} on `#{action}'"
                description << " #{params.inspect}" unless params.blank?
                
                validation_method = self.validation_method
                expected = self.expected
                message = self.message
                
                test_case.it description do
                  send(verb, action, immediate_values(params))
                  send(validation_method).should.messaging(message) == expected
                end
              else
                super
              end
            end
          end
        end
      end
    end
  end
end