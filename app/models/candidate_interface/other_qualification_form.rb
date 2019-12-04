module CandidateInterface
  class OtherQualificationForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :id, :qualification_type, :subject, :institution_name, :grade,
                  :award_year

    validates :qualification_type, :subject, :institution_name, :grade, :award_year, presence: true

    validates :qualification_type, :subject, :institution_name, :grade, length: { maximum: 255 }

    validate :award_year_is_date_and_before_current_year, if: :award_year

    class << self
      def build_all_from_application(application_form)
        application_form.application_qualifications.other.order(:created_at).map do |qualification|
          new_other_qualification_form(qualification)
        end
      end

      def build_from_application(application_form, qualification_id)
        qualification = application_form.application_qualifications.find(qualification_id)

        new_other_qualification_form(qualification)
      end

    private

      def new_other_qualification_form(qualification)
        new(
          id: qualification.id,
          qualification_type: qualification.qualification_type,
          subject: qualification.subject,
          institution_name: qualification.institution_name,
          grade: qualification.grade,
          award_year: qualification.award_year,
        )
      end
    end

    def save(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels[:other],
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
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
      if !valid_year?(award_year)
        errors.add(:award_year, :invalid)
      elsif Date.new(award_year.to_i, 1, 1).year > Date.today.year
        errors.add(:award_year, :in_the_future)
      end
    end
  end
end
