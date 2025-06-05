module CandidateInterface
  class EqualityAndDiversity::SexForm
    include ActiveModel::Model

    attr_accessor :sex

    validates :sex, presence: true

    def self.build_from_application(application_form)
      sex = application_form.equality_and_diversity.present? ? application_form.equality_and_diversity['sex'] : nil

      new(sex:)
    end

    def save(application_form)
      return false unless valid?

      if application_form.equality_and_diversity.nil?
        application_form.update(
          equality_and_diversity: {
            'sex' => sex,
            'hesa_sex' => hesa_sex_code,
          },
        )
      else
        application_form.equality_and_diversity['sex'] = sex
        application_form.equality_and_diversity['hesa_sex'] = hesa_sex_code
        application_form.save
      end
    end

  private

    def hesa_sex_code
      Hesa::Sex.find(sex, current_year)&.hesa_code
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
