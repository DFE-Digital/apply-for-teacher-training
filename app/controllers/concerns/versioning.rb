module Versioning
  extend ActiveSupport::Concern

  included do
    before_action :check_version
  end

private

  def version_param
    params[:api_version]
  end

  def check_version
    if version_number.to_f < self.class::VERSION.to_f
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'InvalidVersionError',
          message: "Not available in version #{version_param}",
        ],
      }
    elsif version_number.to_f > VendorAPI::VERSION.to_f
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
