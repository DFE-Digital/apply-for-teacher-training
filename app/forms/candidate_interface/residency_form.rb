module CandidateInterface
  class ResidencyForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :since_birth

    validates :since_birth, presence: true

    def save(application)
      return false unless valid?

      application.update(country_residency_since_birth: since_birth?)
    end

    def since_birth?
      since_birth == 'yes'
    end

    def self.build_from_application(application_form)
      new(
        since_birth: application_form.country_residency_since_birth ? 'yes' : 'no',
      )
    end
  end
end
