module CandidateInterface
  class PersonalStatementForm
    include ActiveModel::Model

    attr_accessor :personal_statement, :provider_id, :course_id, :study_mode, :site_id

    def available_course_options
      Course.find(course_id).course_options.available
    end
  end
end
