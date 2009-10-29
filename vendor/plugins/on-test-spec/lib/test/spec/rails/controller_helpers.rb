module Test
  module Spec
    module Rails
      module ControllerHelpers
        attr_reader :controller
      end
    end
  end
end

ActionController::TestCase.send(:include, Test::Spec::Rails::ControllerHelpers)