module RemoveBrowserOnlyHeaders
  extend ActiveSupport::Concern

  included do
    before_action :remove_feature_policy_header
  end

  def remove_feature_policy_header
    headers.delete('Feature-Policy')
  end
end
