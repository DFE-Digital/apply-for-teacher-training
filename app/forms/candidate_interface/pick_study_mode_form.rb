module CandidateInterface
  class PickStudyModeForm
    include ActiveModel::Model

    attr_accessor :provider_id, :course_id, :study_mode
    validates :study_mode, presence: true

    def available_sites
      CourseOption.available.where(course_id: course_id, study_mode: study_mode)
    end

    def single_site_course?
      available_sites.one?
    end

    def first_site_id
      available_sites.first&.id
    end
  end
end
