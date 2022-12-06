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
              updated_at: candidate.api_updated_at.iso8601,
              email_address: candidate.email_address,
              application_forms:
                candidate.application_forms.order(:created_at, :id).map do |application|
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
          .select('DISTINCT ON (candidates.id, subquery.api_updated_at) candidates.*, subquery.api_updated_at')
          .from("(#{possibly_relevant_candidate_ids.to_sql}) AS subquery INNER JOIN candidates ON candidates.id = subquery.cid")
          .left_outer_joins(application_forms: { application_choices: %i[provider course interviews], application_references: [] })
          .includes(application_forms: { application_choices: %i[provider course interviews], application_references: [] })
          .where('subquery.api_updated_at > ?', updated_since)
          .order('subquery.api_updated_at DESC')
      end

    private

      def possibly_relevant_candidate_ids
        Candidate
          .select('subq_c.id AS cid, GREATEST(subq_c.updated_at, subq_af.updated_at, subq_ac.updated_at, subq_ar.updated_at, subq_aq.updated_at) AS api_updated_at')
          .from('candidates AS subq_c')
          .joins("
            LEFT OUTER JOIN application_forms AS subq_af ON subq_af.candidate_id = subq_c.id
            LEFT OUTER JOIN application_choices AS subq_ac ON subq_ac.application_form_id = subq_af.id
            LEFT OUTER JOIN \"references\" AS subq_ar ON subq_ar.application_form_id = subq_af.id
            LEFT OUTER JOIN application_qualifications AS subq_aq ON subq_aq.application_form_id = subq_af.id
          ")
          .where('subq_af.recruitment_cycle_year = ? OR subq_c.created_at > ?', RecruitmentCycle.current_year, CycleTimetable.apply_1_deadline(RecruitmentCycle.previous_year))
      end

      def serialize_references(application_form)
        {
          completed: application_form.references_completed,
          data:
            application_form.application_references.creation_order.map do |reference|
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
            application_form.application_choices.order(:id).map do |application_choice|
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
