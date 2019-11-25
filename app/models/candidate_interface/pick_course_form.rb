module CandidateInterface
  class PickCourseForm
    include ActiveModel::Model

    attr_accessor :code, :provider_code
    validates :code, presence: true

    def other?
      code == 'other'
    end

    def available_courses
      Provider
        .find_by(code: provider_code)
        .courses
        .where(exposed_in_find: true)
    end
  end
end
