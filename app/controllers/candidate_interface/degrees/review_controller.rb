module CandidateInterface
  module Degrees
    class ReviewController < BaseController
      def show
        @application_form = current_application
      end

      def complete
        @application_form = current_application

        if @application_form.incomplete_degree_information?
          flash[:warning] = 'You cannot mark this section complete with incomplete degree information.'
          render :show
        else
          @application_form.update!(application_form_params)

          redirect_to candidate_interface_application_form_path
        end
      end

    private

      def application_form_params
        strip_whitespace params.require(:application_form).permit(:degrees_completed)
      end
    end
  end
end
