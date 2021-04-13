module CandidateInterface
  class DegreeCompletionStatusForm
    include ActiveModel::Model

    attr_accessor :degree_completed

    validates :degree_completed, presence: true

    def save(degree)
      return false unless valid?

      degree.update!(predicted_grade: grade_is_predicted?)
    end

    def assign_form_values(degree)
      unless degree.predicted_grade.nil?
        self.degree_completed = degree.predicted_grade? ? 'no' : 'yes'
      end
      self
    end

  private

    def grade_is_predicted?
      degree_completed == 'no'
    end
  end
end
