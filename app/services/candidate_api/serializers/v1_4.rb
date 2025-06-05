module CandidateAPI
  module Serializers
    class V14 < V13
    private

      def serialize_application_form(application_form)
        super.merge!(
          first_name: application_form.first_name,
          last_name: application_form.last_name,
        )
      end

      def serialize_course(course)
        super.merge!(
          level: course.level,
          funding_type: course.funding_type,
          program_type: course.program_type,
        )
      end
    end
  end
end
