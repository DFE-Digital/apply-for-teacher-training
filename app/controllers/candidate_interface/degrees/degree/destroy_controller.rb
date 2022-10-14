module CandidateInterface
  module Degrees
    module Degree
      class DestroyController < BaseController
        before_action :render_application_feedback_component, except: %i[confirm_destroy destroy]

        def confirm_destroy
          @degree = current_degree
          if @degree.nil?
            redirect_to candidate_interface_application_form_path
          end
        end

        def destroy
          current_degree.destroy!
          @wizard = DegreeWizard.new(degree_store)

          if current_application.application_qualifications.degrees.blank?
            current_application.update!(degrees_completed: nil)
            @wizard.clear_state!
          end
          redirect_to candidate_interface_new_degree_review_path
        end

      private

        def degree_store
          key = "degree_wizard_store_#{current_user.id}_#{current_application.id}"
          WizardStateStores::RedisStore.new(key:)
        end
      end
    end
  end
end
