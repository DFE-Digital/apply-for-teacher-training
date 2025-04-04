module CandidateInterface
  module Degrees
    class ReviewController < BaseController
      before_action :set_completed_if_only_foundation_degrees

      def show
        @application_form = current_application
        @section_complete_form = SectionCompleteForm.new(completed: current_application.degrees_completed)
        @wizard = DegreeWizard.new(degree_store)
        @wizard.save_state!
      end

      def complete
        @application_form = current_application
        @section_complete_form = SectionCompleteForm.new(application_form_params)

        if @application_form.incomplete_degree_information? &&
           ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed)
          flash[:warning] = 'You cannot mark this section complete with incomplete degree information.'
          redirect_to candidate_interface_degree_review_path
        elsif @section_complete_form.save(current_application, :degrees_completed)
          if current_application.meets_conditions_for_adviser_interruption? && ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed)
            redirect_to candidate_interface_adviser_sign_ups_interruption_path(@current_application.id)
          else
            redirect_to_candidate_root
          end
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

    private

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end

      def degree_store
        key = "degree_wizard_store_#{current_user.id}_#{current_application.id}"
        WizardStateStores::RedisStore.new(key:)
      end

      def set_completed_if_only_foundation_degrees
        return if current_application.no_degree_and_degree_completed?

        if only_foundation_degrees?
          current_application.update!(degrees_completed: nil)
        end
      end

      def only_foundation_degrees?
        degree_type = current_application.application_qualifications.degrees.pluck(:qualification_type).map do |degree|
          Hesa::DegreeType.find_by_name(degree)&.level
        end
        degree_type.all? { |level| level == :foundation }
      end
    end
  end
end
