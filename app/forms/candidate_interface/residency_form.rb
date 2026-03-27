module CandidateInterface
  class ResidencyForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :since_birth

    validates :since_birth, presence: true

    def save(application)
      return false unless valid?

      application.update!(country_residency_since_birth: since_birth?)

      if application.date_of_birth.present?
        application.update(country_residency_date_from: since_birth? ? application.date_of_birth : nil)
      end
    end

    def since_birth?
      since_birth == 'yes'
    end

    def self.build_from_application(application)
      value = application.country_residency_since_birth

      new(
        since_birth: if value.nil?
                       nil
                     else
                       (value ? 'yes' : 'no')
                     end,
      )
    end
  end
end
