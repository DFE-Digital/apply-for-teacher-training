module CandidateInterface
  class CourseTypePreferenceForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    COURSE_TYPE_OPTIONS = %w[fee salary].freeze

    attribute :course_type, :string
    attribute :preference

    validates :course_type, inclusion: { in: COURSE_TYPE_OPTIONS }

    def save!
      preference.update!(course_type:) if valid?
    end

    def back_link(return_to)
      return_to_review = return_to == 'review'

      if return_to_review
        candidate_interface_draft_preference_path(preference)
      elsif preference.training_locations_anywhere?
        new_candidate_interface_draft_preference_training_location_path(preference)
      else
        new_candidate_interface_draft_preference_dynamic_location_preference_path(preference)
      end
    end
  end
end
