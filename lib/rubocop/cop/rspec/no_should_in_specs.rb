module RuboCop
  module Cop
    module RSpec
      class NoShouldInSpecs < Base
        def_node_matcher :no_should_in_methods, '(send nil? $_)'

        MSG = "Don't use the word 'should' in assertions".freeze

        def on_send(node)
          return unless no_should_in_methods(node)

          add_offense(node) if node.method_name.to_s =~ /should/
        end
      end
    end
  end
end
