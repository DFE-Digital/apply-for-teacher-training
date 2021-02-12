module RuboCop
  module Cop
    module Govuk
      class GovukButtonTo < Base
        def on_send(node)
          return unless node.method_name == :button_to

          add_offense(node, message: 'Use govuk_button_to instead of button_to')
        end
      end
    end
  end
end
