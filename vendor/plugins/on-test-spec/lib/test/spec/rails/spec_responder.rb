module Test
  module Spec
    module Rails
      class SpecResponder
        attr_accessor :test_case
        def initialize(test_case)
          self.test_case = test_case
        end
      end
    end
  end
end