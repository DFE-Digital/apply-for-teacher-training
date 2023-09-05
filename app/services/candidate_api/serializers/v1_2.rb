module CandidateAPI
  module Serializers
    class V12 < Base
      def serialize(candidates)
        super(candidates).map do |candidate|
          candidate[:attributes][:application_forms].each do |form|
            application_form = ApplicationForm.find(form[:id])
            form.merge!(
              application_choices: serialize_application_choices(application_form),
              references: serialize_references(application_form),
              qualifications: serialize_qualifications(application_form),
              personal_statement: serialize_personal_statement(application_form)
            )
          end

          candidate
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
    end
  end
end
