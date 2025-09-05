# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include GovukVisuallyHiddenHelper
  include GovukLinkHelper
  include GovukComponentsHelper
  include GovukListHelper
end
