module CandidateInterface
  class EqualityAndDiversity::DisabilitiesForm
    include ActiveModel::Model
    OTHER = 'Another disability, health condition or impairment affecting daily life'.freeze
    OPT_OUT = 'Prefer not to say'.freeze
    NONE = 'I do not have any of these disabilities or health conditions'.freeze

    attr_accessor :disabilities, :other_disability

    validates :disabilities, presence: true

    def self.build_from_application(application_form)
      return new(disabilities: nil) if application_form.equality_and_diversity.nil?

      application_form_disabilities = Hesa::Disability.convert_disabilities(application_form.equality_and_diversity['disabilities'])
      list_of_disabilities = DisabilityHelper::STANDARD_DISABILITIES.map { |_, disability| disability } + [OTHER, OPT_OUT, NONE]
      listed, other = Array(application_form_disabilities).partition { |d| list_of_disabilities.include?(d) }

      if other.any?
        listed << OTHER

        new(disabilities: listed, other_disability: other.first)
      else
        new(disabilities: listed)
      end
    end

    def save(application_form)
      return false unless valid?

      hesa_codes = hesa_disability_codes

      if disabilities.include?(OTHER) && other_disability.present?
        disabilities.delete(OTHER)
        disabilities << other_disability
      end

      if application_form.equality_and_diversity.nil?
        application_form.update(
          equality_and_diversity: {
            'disabilities' => disabilities,
            'hesa_disabilities' => hesa_codes,
          },
        )
      else
        application_form.equality_and_diversity['disabilities'] = disabilities
        application_form.equality_and_diversity['hesa_disabilities'] = hesa_codes
        application_form.save
      end
    end

  private

    def hesa_disability_codes
      disabilities.map do |disability|
        Hesa::Disability.find(disability, current_year)&.hesa_code
      end.compact
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
