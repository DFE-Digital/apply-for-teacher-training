module CandidateInterface
  module Degrees
    class BaseController < SectionController
      before_action :render_application_feedback_component

      def edit
        @form = Degrees::BaseForm.from_application_qualification(degree_store, current_application.application_qualifications.find(params[:id]))
        @form.save_state!
        redirect_to [:candidate_interface, :degree, params[:step].to_sym]
      end

      def degree_store
        key = "degree_wizard_store_#{current_user.id}_#{current_application.id}"
        WizardStateStores::RedisStore.new(key:)
      end

      def current_degree
        current_application.application_qualifications.degrees.find_by(id: params[:id])
      end
      helper_method :current_degree

      def next_step!
        if @form.next_step == :review
          @form.persist!

          if below_required_for_draft_applications?
            redirect_to candidate_interface_degrees_degree_grade_interruption_path
            return
          end
        end

        redirect_to [:candidate_interface, :degree, @form.next_step]
      end

    private

      def below_required_for_draft_applications?
        return false if current_application.application_choices.empty?

        current_application.application_choices
          .unsubmitted
          .any? { |choice| DegreeGradeEvaluator.new(choice).degree_grade_below_required_grade? }
      end

      def degree_params
        return {} if params[:candidate_interface_degree_form].blank?

        strip_whitespace params.expect(
          candidate_interface_degree_form: %i[uk_or_non_uk country subject subject_raw degree_level equivalent_level
                                              type international_type other_type other_type_raw university university_raw
                                              completed grade other_grade other_grade_raw start_year award_year
                                              enic_reference comparable_uk_degree enic_reason],
        )
      end
    end
  end
end
