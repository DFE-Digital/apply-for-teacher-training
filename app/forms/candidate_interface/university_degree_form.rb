module CandidateInterface
  class UniversityDegreeForm
    include ActiveModel::Model

    attr_accessor :current_application, :university_degree_status

    validates :university_degree_status, presence: true

    def degree?
      ActiveModel::Type::Boolean.new.cast(university_degree_status)
    end
  end
end
