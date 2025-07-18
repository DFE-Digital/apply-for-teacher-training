module ProviderInterface
  class WithdrawnTagOverrideComponent < ApplicationStatusTagComponent
    def text
      return 'Withdrawn' if status == 'withdrawn'

      super
    end
  end
end
