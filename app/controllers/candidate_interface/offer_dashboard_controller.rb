module CandidateInterface
  class OfferDashboardController < CandidateInterfaceController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    before_action :set_application_choice
    before_action :set_references
    after_action :verify_authorized
    after_action :verify_policy_scoped

    def show
      authorize %i[candidate_interface offer_dashboard], :show?
      @provider = @application_choice.current_provider
      @course_name_and_code = @application_choice.current_course.name_and_code
    end

    helper_method def show_provider_contact_component?
      @application_choice.status.in?(%w[
        offer_deferred
        pending_conditions
        recruited
      ])
    end

    def view_reference
      authorize %i[candidate_interface offer_dashboard], :show?
      @reference = @references.find(params.expect(:id))

      redirect_to candidate_interface_references_request_reference_review_path(@reference) if @reference.not_requested_yet?
    end

  private

    def set_application_choice
      @application_choice ||= begin
        choices = active_application_choices.includes(:offer, course_option: [course: :provider])
        choices.pending_conditions.first || choices.recruited.first || choices.offer_deferred.first
      end
    end

    def set_references
      @references ||= policy_scope(
        [:candidate_interface, ApplicationReference],
      ).where(application_form: @application_choice.application_form)
    end
  end
end
