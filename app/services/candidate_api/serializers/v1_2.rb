module CandidateAPI
  module Serializers
    class V12 < Base
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
              candidate.application_forms.sort_by { |form| [form.created_at, form.id] }.map do |application|
                {
                  id: application.id,
                  created_at: application.created_at.iso8601,
                  updated_at: application.updated_at.iso8601,
                  application_status: ApplicationFormStateInferrer.new(application).state,
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
          .left_outer_joins(application_forms: { application_choices: %i[provider course interviews], application_references: [], application_qualifications: [] })
          .includes(application_forms: { application_choices: %i[provider course course_option interviews], application_qualifications: [], application_references: [] })
          .where('candidates.updated_at > :updated_since OR application_forms.updated_at > :updated_since OR application_choices.updated_at > :updated_since OR "references".updated_at > :updated_since OR application_qualifications.updated_at > :updated_since', updated_since:)
          .where('application_forms.recruitment_cycle_year = ? OR candidates.created_at > ?', RecruitmentCycle.current_year, CycleTimetable.apply_1_deadline(RecruitmentCycle.previous_year))
          .order(id: :asc)
          .distinct
      end

    private

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
            application_form.application_references.sort_by(&:created_at).map do |reference|
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

      def serialize_application_choices(application_form)
        {
          completed: application_form.course_choices_completed,
          data:
            application_form.application_choices.sort_by(&:id).map do |application_choice|
              {
                id: application_choice.id,
                created_at: application_choice.created_at&.iso8601,
                updated_at: application_choice.updated_at&.iso8601,
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
