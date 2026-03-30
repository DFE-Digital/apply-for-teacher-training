class VendorAPIRequest < ApplicationRecord
  belongs_to :provider, optional: true
  scope :unprocessable_entities, -> { where(status_code: 422) }
  scope :syncs, -> { where(request_path: '/api/v1/applications', request_method: 'GET') }
  scope :decisions, -> { where(request_method: 'POST') }
  scope :errors, -> { where.not(status_code: [200, 302, 301]) }
  scope :successful, -> { where(status_code: [200]) }

  def self.list_of_distinct_errors_with_count(requests = current_recruitment_unprocessable_entities)
    error_requests = requests
                       .select(:request_path, :response_body, Arel.sql("response_body -> 'errors' as response_errors"))
                       .where.not(response_body: [nil, {}])
                       .where("(response_body->'errors') IS NOT NULL")
    error_messages = error_requests.map do |request|
      [request.request_path, request.response_errors.first['error'], request.response_errors.first['message']]
    end

    tally_errors(error_messages)
  end

  def self.search_validation_errors(params)
    scope = current_recruitment_unprocessable_entities
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

  def self.current_recruitment_unprocessable_entities
    unprocessable_entities.where('created_at > ?', RecruitmentCycleTimetable.current_timetable.apply_opens_at)
  end

  private_class_method :tally_errors
end
