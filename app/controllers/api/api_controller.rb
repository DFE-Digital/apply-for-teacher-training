class API::APIController < ActionController::API
  before_action :check_version

private

  def version_param
    params.permit('version')['version'] || self.class::VERSION
  end

  def check_version
    return unless version_param

    if version_param < self.class::VERSION
      return render json: { error: "Not available in version #{version_param}" }
    end
  end
end
