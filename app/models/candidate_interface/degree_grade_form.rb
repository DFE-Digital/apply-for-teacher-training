module CandidateInterface
  class DegreeGradeForm
    include ActiveModel::Model

    CLASSES = %w[first upper_second lower_second third].freeze

    attr_accessor :grade, :other_grade, :predicted_grade, :degree

    validates :grade, presence: true
    validates :other_grade, presence: true, if: :other_grade?
    validates :predicted_grade, presence: true, if: :predicted_grade?

    def save
      return false unless valid?

      degree.update!(grade: determine_grade)
    end

  private

    def other_grade?
      grade == 'other'
    end

    def predicted_grade?
      grade == 'predicted'
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
