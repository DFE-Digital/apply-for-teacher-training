class API::APIController < ActionController::API
  before_action :check_version, :check_module_version

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

  def check_module_version
    return unless defined?(self.class::VERSIONS)

    owner = method(params[:action]).owner
    self.class::VERSIONS.each do |version, modules|
      modules.each do |mod|
        if mod.constantize.eql?(owner) && version > version_param
          return render json: { error: "Not available in version #{version_param}" }
        end
      end
    end
  end
end
