class VendorAPIRequest < ApplicationRecord
  belongs_to :provider, optional: true
  scope :unprocessable_entities, -> { where(status_code: 422) }
  scope :syncs, -> { where(request_path: '/api/v1/applications', request_method: 'GET') }
  scope :decisions, -> { where(request_method: 'POST') }
  scope :errors, -> { where.not(status_code: [200, 302, 301]) }
  scope :successful, -> { where(status_code: [200]) }

  def self.list_of_distinct_errors_with_count
    error_messages = unprocessable_entities.flat_map do |request|
      request.response_body['errors']&.map do |error|
        [request.request_path, error['error'], error['message']]
      end
    end

    tally_errors(error_messages)
  end

  def self.search_validation_errors(params)
    scope = unprocessable_entities
    scope = scope.where(request_path: params[:request_path]) if params[:request_path]
    scope = scope.where(provider_id: params[:provider_id]) if params[:provider_id]
    scope = scope.where(id: params[:id]) if params[:id]
    scope = scope.where('response_body@> ?', { errors: [{ error: params[:attribute] }] }.to_json) if params[:attribute]
    scope
  end

  def self.tally_errors(error_messages)
    error_messages
      .tally
      .sort_by { |_attributes, total| total }
      .reverse
  end

  private_class_method :tally_errors
end
