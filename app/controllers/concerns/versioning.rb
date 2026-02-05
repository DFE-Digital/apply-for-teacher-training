module Versioning
  extend ActiveSupport::Concern
  include VersioningHelpers

private

  def version_param
    params[:api_version]
  end

  def version_number
    extracted_from_param = extract_version(version_param)
    @version_number ||= "#{major_version_number(extracted_from_param)}.#{minor_version_number(extracted_from_param)}"
  end
end
