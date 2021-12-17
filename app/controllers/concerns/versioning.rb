module Versioning
  extend ActiveSupport::Concern
  include VersioningHelpers

private

  def version_param
    params[:api_version]
  end

  def version_number
    @version_number = extract_version(version_param)
  end
end
