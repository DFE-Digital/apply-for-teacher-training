module CandidateInterface
  class ResidencyForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :application_form

    attribute :since_birth

    validate :since_birth_presence

    def save
      return false unless valid?

      application_form.update!(country_residency_since_birth: since_birth?)

      if application_form.date_of_birth.present?
        application_form.update(country_residency_date_from: since_birth? ? application_form.date_of_birth : nil)
      end
    end

    def since_birth?
      since_birth == 'yes'
    end

    def self.build_from_application(application)
      value = application.country_residency_since_birth

      new(
        {
          since_birth: if value.nil?
                         nil
                       else
                         (value ? 'yes' : 'no')
                       end,
          application_form: application,
        },
      )
    end

    def since_birth_presence
      if since_birth.blank?
        errors.add(:since_birth, :blank, country: application_form.country_of_residence)
      end
    end
  end
end
