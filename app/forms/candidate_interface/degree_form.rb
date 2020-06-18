module CandidateInterface
  class DegreeForm
    include ActiveModel::Model
    include ValidationUtils

    CLASSES = %w[first upper_second lower_second third].freeze

    attr_accessor :id, :qualification_type, :subject, :institution_name, :grade,
                  :other_grade, :predicted_grade, :start_year, :award_year

    validates :qualification_type, :subject, :institution_name, presence: true, on: :base
    validates :grade, presence: true, on: :grade
    validates :other_grade, presence: true, if: :other_grade?, on: :grade
    validates :predicted_grade, presence: true, if: :predicted_grade?, on: :grade
    validates :award_year, presence: true, on: :award_year

    validates :qualification_type, :subject, :institution_name, length: { maximum: 255 }, on: :base
    validates :grade, length: { maximum: 255 }, on: :grade
    validates :other_grade, :predicted_grade, length: { maximum: 255 }, on: :grade

    validate :start_year_is_valid_date, if: :start_year, on: :start_year
    validate :award_year_is_valid_date, if: :award_year, on: :award_year

    class << self
      def build_all_from_application(application_form)
        application_form.application_qualifications.degrees.order(created_at: :desc).map do |degree|
          new_degree_form(degree)
        end
      end

      def build_from_qualification(qualification)
        new_degree_form(qualification)
      end

    private

      def new_degree_form(degree)
        grade = determine_application_grade(degree.grade, degree.predicted_grade)

        new(
          id: degree.id,
          qualification_type: degree.qualification_type,
          subject: degree.subject,
          institution_name: degree.institution_name,
          grade: grade,
          other_grade: grade == 'other' ? degree.grade : '',
          predicted_grade: degree.predicted_grade ? degree.grade : '',
          start_year: degree.start_year,
          award_year: degree.award_year,
        )
      end

      def determine_application_grade(grade, predicted_grade)
        case grade
        when *CLASSES
          grade
        else
          if predicted_grade
            'predicted'
          else
            'other'
          end
        end
      end
    end

    def save_base(application_form)
      return false unless valid?(:base)

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels['degree'],
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
      )
    end

    def update_grade(application_form)
      return false unless valid?(:grade)

      degree = application_form.application_qualifications.find(id)

      degree.update!(
        grade: determine_grade,
        predicted_grade: predicted_grade? ? true : false,
      )

      true
    end

    def update_year(application_form)
      return false unless valid?(:start_year) && valid?(:award_year)

      degree = application_form.application_qualifications.find(id)

      degree.update!(
        start_year: start_year,
        award_year: award_year,
      )

      true
    end

    def update_base(application_form)
      return false unless valid?(:base)

      degree = application_form.application_qualifications.find(id)

      degree.update!(
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
      )
    end

    def title
      "#{qualification_type} #{subject}"
    end

  private

    def other_grade?
      grade == 'other'
    end

    def predicted_grade?
      grade == 'predicted'
    end

    def start_year_is_valid_date
      return true if start_year.blank?

      if valid_year?(start_year)
        start_year_is_before_the_award_year
      else
        start_year_is_invalid
      end
    end

    def award_year_is_valid_date
      if valid_year?(award_year)
        award_year_is_before_the_end_of_next_year
      else
        award_year_is_invalid
      end
    end

    def start_year_is_invalid
      errors.add(:start_year, :invalid)
    end

    def award_year_is_invalid
      errors.add(:award_year, :invalid)
    end

    def start_year_is_before_the_award_year
      errors.add(:start_year, :greater_than_award_year, date: award_year) if award_year.present? && award_year.to_i < start_year.to_i
    end

    def award_year_is_before_the_end_of_next_year
      upper_year_limit = Time.zone.now.year.to_i + 2

      errors.add(:award_year, :greater_than_limit, date: upper_year_limit) if award_year.to_i >= upper_year_limit
    end

    def determine_grade
      case grade
      when 'other'
        other_grade
      when 'predicted'
        predicted_grade
      else
        grade
      end
    end
  end
end
