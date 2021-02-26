module RuboCop
  module Cop
    module Govuk
      class GovukSubmit < Base
        def on_send(node)
          return unless node.method_name == :submit

          add_offense(node, message: 'Use govuk_submit instead of submit')
        end
      end
    end
  end
end
