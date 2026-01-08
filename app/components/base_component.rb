class BaseComponent < ViewComponent::Base
  include GovukVisuallyHiddenHelper
  include GovukLinkHelper
  include GovukComponentsHelper
  include GovukListHelper
end
