module Versioning
  extend ActiveSupport::Concern
  include VersioningHelpers

  included do
    before_action :check_version
  end

private

  def version_param
    params[:api_version]
  end

  def check_version
    if minor_version(version_number) < minor_version(self.class::VERSION)
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'InvalidVersionError',
          message: "Not available in version #{version_param}",
        ],
      }
    elsif minor_version(version_number) > minor_version(VendorAPI::VERSION)
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'NonExistentVersionError',
          message: "Version #{version_param} does not exist",
        ],
      }
    end
  end

  def version_number
    @version_number ||= version_param.scan(/1\.?\d*/).first
  end
end
