module CandidateInterface
  class ApplicationSubmitController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show
      @application_form = current_candidate.current_application
    end

    def submit
      @application_form = current_candidate.current_application

      # TODO: Show and Tell HACK
      application_not_submitted = @application_form.application_choices.first.status != 'application_complete'
      if application_not_submitted
        @application_form.application_choices.each do |application_choice|
          ApplicationStateChange.new(application_choice).submit!
        end
      end

      render :success
    end
  end
end
