module CandidateInterface
  class ImmigrationStatusForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :immigration_status, :immigration_status_details, :nationalities

    before_validation :set_default_status
    validates :immigration_status, presence: true
    validates :immigration_status_details, presence: true, if: :other_immigration_status?
    validates :immigration_status_details, word_count: { maximum: 200 }

    DEFAULT_IMMIGRATION_STATUS = 'other'.freeze

    def set_default_status
      self.immigration_status ||= DEFAULT_IMMIGRATION_STATUS
    end

    def self.build_from_application(application_form)
      new(
        immigration_status: application_form.immigration_status,
        immigration_status_details: application_form.immigration_status_details,
        nationalities: application_form.nationalities,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        immigration_status: immigration_status,
        immigration_status_details: other_immigration_status? ? immigration_status_details : nil,
        immigration_route: nil,
        immigration_route_details: nil,
      )
    end

    def eu_nationality?
      return false if nationalities.blank?

      (EU_EEA_SWISS_COUNTRY_CODES & nationalities.map { |name| NATIONALITIES_BY_NAME[name] }).any?
    end

    def other_immigration_status?
      immigration_status == 'other'
    end
  end
end
