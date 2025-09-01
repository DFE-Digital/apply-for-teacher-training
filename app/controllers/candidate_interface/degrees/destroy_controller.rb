module CandidateInterface
  module Degrees
    class DestroyController < BaseController
      before_action :render_application_feedback_component, except: %i[confirm_destroy destroy]
      before_action :redirect_to_review_page, unless: -> { current_degree }

      def confirm_destroy
        @degree = current_degree
      end

      def destroy
        current_degree.destroy!
        @form = BaseForm.new(degree_store)

        if current_application.application_qualifications.degrees.blank?
          current_application.update!(degrees_completed: nil)
          @form.clear_state!

          return redirect_to candidate_interface_details_path
        end
        redirect_to candidate_interface_degree_review_path
      end

    private

      def degree_store
        key = "degree_wizard_store_#{current_user.id}_#{current_application.id}"
        WizardStateStores::RedisStore.new(key:)
      end

      def redirect_to_review_page
        redirect_to candidate_interface_degree_review_path
      end
    end
  end
end
