module CandidateAPI
  module Serializers
    class V12
      attr_reader :updated_since

      def initialize(updated_since:)
        @updated_since = updated_since
      end

      def serialize(candidates)
        candidates.map do |candidate|
          {
            id: candidate.public_id,
            type: 'candidate',
            attributes: {
              created_at: candidate.created_at.iso8601,
              updated_at: candidate.candidate_api_updated_at,
              email_address: candidate.email_address,
              application_forms:
                candidate.application_forms.order(:created_at).map do |application|
                  {
                    id: application.id,
                    created_at: application.created_at.iso8601,
                    updated_at: application.updated_at.iso8601,
                    application_status: ProcessState.new(application).state,
                    application_phase: application.phase,
                    recruitment_cycle_year: application.recruitment_cycle_year,
                    submitted_at: application.submitted_at&.iso8601,
                    application_choices: serialize_application_choices(application),
                    references: serialize_references(application),
                    qualifications: serialize_qualifications(application),
                    personal_statement: serialize_personal_statement(application),
                  }
                end,
            },
          }
        end
      end

      def query
        Candidate
        .left_outer_joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_1_deadline(RecruitmentCycle.previous_year)))
        .distinct
        .includes(application_forms: { application_choices: [:provider, :course, :interviews], application_references: [] })
        .where('candidate_api_updated_at > ?', updated_since)
        .order('candidates.candidate_api_updated_at DESC')
      end

    private

      def serialize_references(application_form)
        {
          completed: application_form.references_completed,
          data:
            application_form.application_references.order(:id).map do |reference|
              {
                id: reference.id,
                requested_at: reference.requested_at.iso8601,
                feedback_status: reference.feedback_status,
                referee_type: reference.referee_type,
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

      def serialize_application_choices(application_form)
        {
          completed: application_form.course_choices_completed,
          data:
            application_form.application_choices.order(:id).map do |application_choice|
              {
                id: application_choice.id,
                status: application_choice.status,
                provider: serialize_provider(application_choice.provider),
                course: serialize_course(application_choice.course),
                interviews: serialize_interviews(application_choice),
              }
            end,
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
