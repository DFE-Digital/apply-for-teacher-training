module RuboCop
  module Cop
    module RSpec
      class RSpecDescribeSystemSpecs < Base
        extend AutoCorrector
        include RangeHelp

        def_node_matcher :rspec_describe_system_specs?, <<~PATTERN
          $(send (const nil? :RSpec) :feature ...)
        PATTERN

        MSG = 'Change RSpec.feature to RSpec.describe'.freeze

        def on_send(node)
          expr = rspec_describe_system_specs?(node)
          return unless expr

          range = node.receiver.source_range
          range = range.resize(range.size + node.method_name.length + 1)

          add_offense(range) do |corrector|
            corrector.replace(expr, expr.source.sub('feature', 'describe'))
          end
        end
      end
    end
  end
end
