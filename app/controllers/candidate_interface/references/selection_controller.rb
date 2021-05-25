module CandidateInterface
  module References
    class SelectionController < BaseController
      before_action :render_404_unless_feature_enabled
      before_action :redirect_to_select_references_unless_enough_selected, only: %i[review complete]

      def new
        @selection_form = CandidateInterface::Reference::SelectionForm.new(
          application_form: current_application,
          selected: current_application.application_references.selected.pluck(:id),
        )
        @enough_references_provided = current_application.minimum_references_available_for_selection?
      end

      def create
        @selection_form = CandidateInterface::Reference::SelectionForm.new(selection_params)
        @enough_references_provided = current_application.minimum_references_available_for_selection?

        if @selection_form.save!
          track_validation_error(@section_complete_form)
          redirect_to candidate_interface_review_selected_references_path
        elsif !@enough_references_provided
          flash.now[:warning] = I18n.t('application_form.references.review.need_two')
          render :new and return
        else
          track_validation_error(@selection_form)
          render :new
        end
      end

      def review
        @references_selected = current_application.application_references.includes(:application_form).selected
        @section_complete_form = SectionCompleteForm.new(completed: current_application.references_completed)

        @selected_references_rows = [
          {
            key: 'Selected references',
            value: reference_values,
            action: 'Change selected references',
            change_path: candidate_interface_select_references_path,
          },
        ]
      end

      def complete
        @references_selected = current_application.application_references.includes(:application_form).selected
        @section_complete_form = SectionCompleteForm.new(completed: section_complete_params[:completed])

        @selected_references_rows = [
          {
            key: 'Selected references',
            value: reference_values,
            action: 'Change selected references',
            change_path: candidate_interface_select_references_path,
          },
        ]

        if !@section_complete_form.valid?
          track_validation_error(@section_complete_form)
          render :review and return
        end

        if @section_complete_form.not_completed?
          @section_complete_form.save(current_application, :references_completed)
          redirect_to candidate_interface_application_form_path
        elsif current_application.selected_enough_references?
          @section_complete_form.save(current_application, :references_completed)
          redirect_to candidate_interface_application_form_path
        end
      end

    private

      def redirect_to_select_references_unless_enough_selected
        if current_application.application_references.includes(:application_form).selected.count != 2
          redirect_to candidate_interface_select_references_path
        end
      end

      def selection_params
        params.require(:candidate_interface_reference_selection_form).permit(selected: [])
          .merge(application_form: current_application)
      end

      def section_complete_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end

      def reference_values
        list = '<ul class="govuk-list govuk-list--bullet">'.html_safe
        @references_selected.map do |reference|
          list <<
            '<li>'.html_safe <<
            "#{reference.referee_type.humanize} reference from #{reference.name}" <<
            '</li>'.html_safe
        end
        list + '</ul>'.html_safe
      end

      def render_404_unless_feature_enabled
        render_404 unless FeatureFlag.active?(:reference_selection)
      end
    end
  end
end
