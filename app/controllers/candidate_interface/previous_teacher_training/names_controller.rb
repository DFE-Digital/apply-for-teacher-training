module CandidateInterface
  module PreviousTeacherTraining
    class NamesController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_back_path

      def edit
        @form = ::PreviousTeacherTraining::Name.find_or_initialize_by(
          application_form: current_application,
        )
      end

      def update
        @form = ::PreviousTeacherTraining::Name.find_or_initialize_by(
          application_form: current_application,
        )

        if @form.update(form_params)
          redirect_to @back_path || edit_candidate_interface_previous_teacher_training_dates_path
        else
          render :edit
        end
      end

    private

      def form_params
        {
          provider_name: request_params[:provider_name_raw] || request_params[:provider_name],
        }
      end

      def request_params
        strip_whitespace(
          params.expect(previous_teacher_training_name: %i[provider_name_raw provider_name]),
        )
      end

      def set_back_path
        if params[:return_to] == 'review'
          @back_path = candidate_interface_previous_teacher_training_review_path
        end
      end
    end
  end
end
