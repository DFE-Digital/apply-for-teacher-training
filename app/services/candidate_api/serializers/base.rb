module CandidateAPI
  module Serializers
    def self.[](version)
      case version
      when 'v1.4'
        V14
      when 'v1.3'
        V13
      when 'v1.2'
        V12
      else
        V11
      end
    end

    class Base
      def serialize(candidates)
        candidates.map do |candidate|
          {
            id: candidate.public_id,
            type: 'candidate',
            attributes: {
              created_at: candidate.created_at.iso8601,
              updated_at: api_updated_at(candidate),
              email_address: candidate.email_address,
              application_forms:
                candidate.application_forms.sort_by { |form| [form.created_at, form.id] }.map(&method(:serialize_application_form)),
            },
          }
        end
      end

    private

      def serialize_application_form(application_form)
        {
          id: application_form.id,
          created_at: application_form.created_at.iso8601,
          updated_at: application_form.updated_at.iso8601,
          application_status: ApplicationFormStateInferrer.new(application_form).state,
          application_phase: application_form.phase,
          recruitment_cycle_year: application_form.recruitment_cycle_year,
          submitted_at: application_form.submitted_at&.iso8601,
        }
      end

      def api_updated_at(candidate)
        [
          candidate.updated_at,
          candidate.application_choices.map(&:updated_at),
          candidate.application_forms.map do |application_form|
            [
              application_form.updated_at,
              application_form.application_references.map(&:updated_at),
              application_form.application_qualifications.map(&:updated_at),
            ]
          end,
        ].flatten.max.iso8601
      end

      def serialize_references(application_form)
        {
          completed: application_form.references_completed,
          data:
          application_form.application_references.sort_by(&:id).map do |reference|
            {
              id: reference.id,
              requested_at: reference.requested_at&.iso8601,
              feedback_status: reference.feedback_status,
              referee_type: reference.referee_type,
              created_at: reference.created_at.iso8601,
              updated_at: reference.updated_at.iso8601,
            }
          end,
        }
      end

      def serialize_qualifications(application_form)
        {
          completed: application_form.qualifications_completed?,
        }
      end

      def serialize_personal_statement(application_form)
        {
          completed: application_form.becoming_a_teacher_completed,
        }
      end

      def serialize_provider(provider)
        {
          name: provider.name,
        }
      end

      def serialize_course(course)
        {
          uuid: course.uuid,
          name: course.name,
        }
      end

      def serialize_interviews(application_choice)
        application_choice.interviews.map do |interview|
          serialize_interview(interview)
        end
      end

      def serialize_interview(interview)
        {
          id: interview.id,
          date_and_time: interview.date_and_time&.iso8601,
          created_at: interview.created_at&.iso8601,
          updated_at: interview.updated_at&.iso8601,
          cancelled_at: interview.cancelled_at&.iso8601,
        }
      end
    end
  end
end
