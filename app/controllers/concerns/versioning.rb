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

  def full_api_version_number
    "#{major_version_number(version_number)}.#{minor_version_number(version_number)}"
  end
end
