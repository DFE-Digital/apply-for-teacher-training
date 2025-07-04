class CandidateInterface::DynamicLocationPreferencesForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Rails.application.routes.url_helpers

  attribute :dynamic_location_preferences, :boolean
  attribute :preference

  validates :dynamic_location_preferences, inclusion: { in: [true, false] }

  def save
    preference.update!(dynamic_location_preferences:) if valid?
  end

  def next_path(return_to)
    # test this
    return_to_review = return_to == 'review'
    return candidate_interface_draft_preference_path(preference) if return_to_review

    if preference.applied_only_to_salaried_courses?
      new_candidate_interface_draft_preference_course_type_preference_path(preference)
    else
      candidate_interface_draft_preference_path(preference)
    end
  end
end
