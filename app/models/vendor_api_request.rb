class VendorAPIRequest < ApplicationRecord
  belongs_to :provider, optional: true
  scope :validation_errors, -> { where(status_code: 422) }

  def self.list_of_distinct_errors_with_count
    distinct_errors = validation_errors.flat_map do |request|
      request.response_body['errors']&.map do |error|
        [request.request_path, error['error'], error['message']]
      end
    end

    tally_errors(distinct_errors)
  end

  def self.search_validation_errors(params)
    scope = validation_errors
    scope = scope.where(request_path: params[:request_path]) if params[:request_path]
    scope = scope.where(provider_id: params[:provider_id]) if params[:provider_id]
    scope = scope.where(id: params[:id]) if params[:id]
    scope = scope.where('response_body@> ?', { errors: [{ error: params[:attribute] }] }.to_json) if params[:attribute]
    scope
  end

  def self.tally_errors(distinct_errors)
    distinct_errors
      .tally
      .sort_by { |_attributes, total| total }
      .reverse
  end

  private_class_method :tally_errors
end
