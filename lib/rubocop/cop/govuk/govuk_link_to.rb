module RuboCop
  module Cop
    module Govuk
      class GovukLinkTo < Base
        def on_send(node)
          return unless node.method_name == :link_to

          add_offense(node, message: 'Use govuk_link_to or govuk_button_link_to instead of link_to')
        end
      end
    end
  end
end
