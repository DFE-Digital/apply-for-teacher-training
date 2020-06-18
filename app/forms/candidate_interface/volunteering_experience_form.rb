module CandidateInterface
  class VolunteeringExperienceForm
    include ActiveModel::Model

    attr_accessor :experience

    validates :experience, presence: true

    def save(application_form)
      return false unless valid?

      application_form.update!(volunteering_experience: ActiveModel::Type::Boolean.new.cast(experience))
    end
  end
end
