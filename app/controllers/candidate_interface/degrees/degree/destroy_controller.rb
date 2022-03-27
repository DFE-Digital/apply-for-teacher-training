module CandidateInterface
  module Degrees
    module Degree
      class DestroyController < BaseController
        before_action :redirect_to_old_degree_flow_unless_feature_flag_is_active
        before_action :render_application_feedback_component, except: %i[confirm_destroy destroy]

        def confirm_destroy
          @degree = current_degree
        end

        def destroy
          current_degree.destroy!

          if current_application.application_qualifications.degrees.blank?
            current_application.update!(degrees_completed: nil)
            redirect_to candidate_interface_new_degree_country_path
          else
            redirect_to candidate_interface_new_degree_review_path
          end
        end

      private

        def redirect_to_old_degree_flow_unless_feature_flag_is_active
          redirect_to candidate_interface_new_degree_path unless FeatureFlag.active?(:new_degree_flow)
        end
      end
    end
  end
end
