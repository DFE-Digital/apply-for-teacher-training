module CandidateInterface
  class EqualityAndDiversity::DisabilityStatusForm
    include ActiveModel::Model

    attr_accessor :disability_status

    validates :disability_status, presence: true

    def self.build_from_application(application_form)
      return new(disability_status: nil) if application_form.equality_and_diversity.nil?
      return new(disability_status: nil) if application_form.equality_and_diversity['disabilities'].nil?
      return new(disability_status: 'Prefer not to say') if application_form.equality_and_diversity['disabilities'].include?('Prefer not to say')
      return new(disability_status: 'yes') if application_form.equality_and_diversity['disabilities'].any?

      new(disability_status: 'no')
    end

    def save(application_form)
      return false unless valid?

      application_form.equality_and_diversity ||= {}

      if application_form.equality_and_diversity['disabilities'].nil? || reset_disabilities?(application_form)
        application_form.equality_and_diversity['disabilities'] = []
        application_form.equality_and_diversity['hesa_disabilities'] = [hesa_code].compact
        application_form.save
      elsif disability_status == 'Prefer not to say'
        application_form.equality_and_diversity['disabilities'] = ['Prefer not to say']
        application_form.equality_and_diversity['hesa_disabilities'] = []
        application_form.save
      else
        true
      end
    end

  private

    def hesa_code
      if disability_status == 'no'
        Hesa::Disability
          .find(disability_status)
          .hesa_code
      end
    end

    def reset_disabilities?(application_form)
      disability_status == 'no' ||
        application_form.equality_and_diversity['disabilities'].include?('Prefer not to say')
    end
  end
end
