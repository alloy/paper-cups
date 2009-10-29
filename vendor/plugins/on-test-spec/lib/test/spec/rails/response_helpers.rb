module Test
  module Spec
    module Rails
      class Status < SpecResponder
        def should_equal(status, message=nil)
          @test_case.send(:assert_response, status, message)
        end
      end
      
      class Template < SpecResponder
        def should_equal(template, message=nil)
          @test_case.send(:assert_template, template, message)
        end
      end
      
      class Layout < SpecResponder
        def should_equal(layout, message=nil)
          rendered_layout = @test_case.response.layout.gsub(/layouts\//, '')
          @test_case.send(:assert_equal, layout, rendered_layout, message)
        end
      end
      
      module ResponseHelpers
        attr_reader :response
        
        def status
          Test::Spec::Rails::Status.new(self)
        end
        
        def template
          Test::Spec::Rails::Template.new(self)
        end
        
        def layout
          Test::Spec::Rails::Layout.new(self)
        end
      end
    end
  end
end

ActionController::TestCase.send(:include, Test::Spec::Rails::ResponseHelpers)