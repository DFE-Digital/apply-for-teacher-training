module TouchCandidateAPIUpdatedAt
  extend ActiveSupport::Concern

  included do
    before_save do |object|
      object.application_form.candidate.update_column(:candidate_api_updated_at, Time.zone.now) if !object.application_form.candidate.new_record? && object.application_form.created_at == object.application_form.updated_at
    end
  end
end
