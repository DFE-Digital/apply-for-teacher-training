module CandidateInterface
  class OtherQualificationForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :id, :qualification_type, :subject, :institution_name, :grade,
                  :award_year, :choice, :non_uk_qualification_type, :other_uk_qualification_type,
                  :institution_country

    validates :qualification_type, :institution_name, :award_year, presence: true

    validates :choice, presence: true, on: :save

    validates :subject, :grade, presence: true, unless: -> { qualification_type == 'non_uk' || qualification_type == 'Other' }

    validates :institution_country, presence: true, if: -> { qualification_type == 'non_uk' }

    validates :institution_country, inclusion: { in: COUNTRY_NAMES }, if: -> { qualification_type == 'non_uk' }

    validates :qualification_type, :subject, :institution_name, :grade, length: { maximum: 255 }

    validate :award_year_is_date_and_before_current_year, if: :award_year

    class << self
      def build_all_from_application(application_form)
        application_form.application_qualifications.other.order(:created_at).map do |qualification|
          new_other_qualification_form(qualification)
        end
      end

      def build_from_qualification(qualification)
        new_other_qualification_form(qualification)
      end

    private

      def new_other_qualification_form(qualification)
        new(
          id: qualification.id,
          qualification_type: qualification.qualification_type,
          subject: qualification.subject,
          institution_name: qualification.institution_name,
          institution_country: COUNTRIES[qualification.institution_country],
          grade: qualification.grade,
          award_year: qualification.award_year,
          other_uk_qualification_type: qualification.other_uk_qualification_type,
          non_uk_qualification_type: qualification.non_uk_qualification_type,
        )
      end
    end

    def save
      return false unless valid?

      qualification = ApplicationQualification.find(id)
      qualification.update!(
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
        institution_country: COUNTRY_NAMES_TO_ISO_CODES[institution_country],
        grade: grade,
        predicted_grade: false,
        award_year: award_year,
      )
      true
    end

    def update(application_form)
      return false unless valid?

      qualification = application_form.application_qualifications.find(id)

      qualification.update!(
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
        institution_country: COUNTRY_NAMES_TO_ISO_CODES[institution_country],
        grade: grade,
        predicted_grade: false,
        award_year: award_year,
      )
    end

    def title
      "#{qualification_type} #{subject}"
    end

  private

    def award_year_is_date_and_before_current_year
      year_limit = Date.today.year.to_i + 1

      if !valid_year?(award_year)
        errors.add(:award_year, :invalid)
      elsif award_year.to_i >= year_limit
        errors.add(:award_year, :in_the_future, date: year_limit)
      end
    end
  end
end
