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

      def serialize_application_choices(application_form)
        {
          data:
          application_form.application_choices.sort_by(&:id).map do |application_choice|
            {
              id: application_choice.id,
              created_at: application_choice.created_at&.iso8601,
              updated_at: application_choice.updated_at&.iso8601,
              sent_to_provider_at: application_choice.sent_to_provider_at&.iso8601,
              accepted_at: application_choice.accepted_at&.iso8601,
              status: application_choice.status,
              provider: serialize_provider(application_choice.provider),
              course: serialize_course(application_choice.course),
              interviews: serialize_interviews(application_choice),
            }
          end,
        }
      end
    end
  end
end
