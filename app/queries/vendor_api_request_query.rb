class VendorAPIRequestQuery
  attr_reader :params

  LIMIT = 5000

  def initialize(params: {})
    @params = params
  end

  def self.call(...)
    new(...).call
  end

  def call
    scope = VendorAPIRequest.includes(:provider).order(id: :desc)
    scope = search_scope(scope)
    scope = status_code_scope(scope)
    scope = request_method_scope(scope)
    scope = provider_scope(scope)
    scope.limit(LIMIT)
  end

private

  def search_scope(scope)
    return scope if params[:q].blank?

    scope.where("CONCAT(request_path, ' ', request_body, ' ', response_body) ILIKE ?", "%#{params[:q].strip}%")
  end

  def status_code_scope(scope)
    return scope if params[:status_code].blank?

    scope.where(status_code: params[:status_code])
  end

  def request_method_scope(scope)
    return scope if params[:request_method].blank?

    scope.where(request_method: params[:request_method])
  end

  def provider_scope(scope)
    return scope if params[:provider_code].blank?

    provider = Provider.find_by(code: params[:provider_code].strip.upcase)
    return VendorAPIRequest.none if provider.nil?

    scope.where(provider_id: provider.id)
  end
end
