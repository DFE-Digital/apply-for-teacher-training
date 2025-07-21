module CandidateInterface
  class DecisionsController < CandidateInterfaceController
    before_action :set_application_choice
    before_action :check_that_candidate_can_decline, only: %i[decline_offer confirm_decline]
    before_action :check_that_candidate_can_accept, only: %i[accept_offer confirm_accept]
    before_action :check_that_candidate_has_an_offer, only: %i[offer respond_to_offer]

    def offer
      @respond_to_offer = CandidateInterface::RespondToOfferForm.new
      @offer_count = @application_choice.self_and_siblings.offer.count
      @back_link = if params['return_to'] == 'invites'
                     candidate_interface_invites_path
                   else
                     candidate_interface_application_choices_path
                   end
    end

    def respond_to_offer
      response = params.dig(:candidate_interface_respond_to_offer_form, :response)

      @respond_to_offer = CandidateInterface::RespondToOfferForm.new(response:)

      if @respond_to_offer.invalid?
        @offer_count = @application_choice.self_and_siblings.offer.count
        render :offer
      elsif @respond_to_offer.decline?
        redirect_to candidate_interface_decline_offer_path(@application_choice)
      elsif @respond_to_offer.accept?
        redirect_to candidate_interface_accept_offer_path(@application_choice)
      end
    end

    def decline_offer; end

    def confirm_decline
      decline = DeclineOffer.new(application_choice: @application_choice.reload)
      decline.save!
      flash[:success] = "You have declined your offer for #{@application_choice.current_course.name_and_code} at #{@application_choice.provider.name}"
      redirect_to candidate_interface_application_choices_path
    end

    def accept_offer
      @accept_offer = AcceptOffer.new(application_choice: @application_choice.reload)
    end

    def confirm_accept
      @accept_offer = AcceptOffer.new(application_choice: @application_choice.reload)

      if @accept_offer.save!
        flash[:success] = "You have accepted your offer for #{@application_choice.current_course.name_and_code} at #{@application_choice.provider.name}"
        redirect_to candidate_interface_application_choices_path
      else
        track_validation_error(@accept_offer)
        render :accept_offer
      end
    end

  private

    def set_application_choice
      @application_choice = @current_application.application_choices.find(params[:id])
    end

    def single_application_choice?
      @current_application.application_choices.size == 1
    end
    helper_method :single_application_choice?

    def check_that_candidate_can_decline
      unless ApplicationStateChange.new(@application_choice).can_decline?
        render_404
      end
    end

    def course_choice_rows
      [].tap do |collection|
        collection << { key: 'Provider', value: @application_choice.current_course.provider.name }
        collection << { key: 'Course', value: @application_choice.current_course.name_and_code }
        if !@application_choice.school_placement_auto_selected?
          collection << { key: 'Location', value: @application_choice.current_course_option.site.name }
        end
      end
    end
    helper_method :course_choice_rows
  end
end
