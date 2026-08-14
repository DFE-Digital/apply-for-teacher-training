class VendorAPIRequestQuery
  attr_reader :params
  COLUMNS = %w[id created_at provider_id request_body request_headers request_method
               request_path response_body response_headers status_code].freeze

  LIMIT = 5000

  def initialize(params: {})
    @params = params
  end

  def self.call(...)
    new(...).call
  end

  def call
    scope = VendorAPIRequest.includes(:provider).order(id: :desc)
    second_scope = VendorAPIRequestV2.includes(:provider).order(id: :desc)

    scope = search_scope(scope)
    second_scope = search_scope(second_scope)

    scope = status_code_scope(scope)
    second_scope = status_code_scope(second_scope)

    scope = request_method_scope(scope)
    second_scope = request_method_scope(second_scope)

    scope = provider_scope(scope)
    second_scope = provider_scope(second_scope)

    sql = <<-SQL
      (#{scope.reselect(COLUMNS).to_sql})
      UNION ALL
      (#{second_scope.reselect(COLUMNS).to_sql})
      ORDER BY created_at DESC LIMIT #{LIMIT}
    SQL

    records = ActiveRecord::Base.connection.execute(sql)
    providers_hash = Provider.where(
      id: records.map { |r| r.fetch('provider_id') }.uniq,
    ).index_by(&:id)

    records.map do |record|
      VendorAPIRequestPresenter.new(record, providers_hash:)
    end
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

class VendorAPIRequestPresenter
  attr_reader :id, :created_at, :provider, :request_body,
              :request_headers, :request_method, :request_path, :response_body,
              :response_headers, :status_code

  def initialize(response_hash, providers_hash:)
    @id = response_hash.fetch('id')
    @created_at = response_hash.fetch('created_at')
    @provider = providers_hash.fetch(response_hash.fetch('provider_id'))
    @request_body = response_hash.fetch('request_body')
    @request_headers = response_hash.fetch('request_headers')
    @request_method = response_hash.fetch('request_method')
    @request_path = response_hash.fetch('request_path')
    @response_body = response_hash.fetch('response_body')
    @response_headers = response_hash.fetch('response_headers')
    @status_code = response_hash.fetch('status_code')
  end
end
