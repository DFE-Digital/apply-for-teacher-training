module CandidateInterface
  class FundingTypePreferenceForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    FUNDING_TYPE_OPTIONS = %w[fee salary].freeze

    attribute :funding_type, :string
    attribute :preference

    validates :funding_type, inclusion: { in: FUNDING_TYPE_OPTIONS }

    def save!
      preference.update!(funding_type:) if valid?
    end

    def back_path(return_to: nil)
      if return_to == 'review'
        candidate_interface_draft_preference_path(preference)
      elsif preference.training_locations_anywhere?
        new_candidate_interface_draft_preference_training_location_path(preference)
      else
        new_candidate_interface_draft_preference_dynamic_location_preference_path(preference)
      end
    end
  end
end
