module Test
  module Spec
    module Rails
      module RequestHelpers
        attr_reader :request
      end
    end
  end
end

ActionController::TestCase.send(:include, Test::Spec::Rails::RequestHelpers)