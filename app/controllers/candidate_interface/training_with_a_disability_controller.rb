module CandidateInterface
  class TrainingWithADisabilityController < CandidateInterfaceController
    def edit
      @training_with_a_disability_form = TrainingWithADisabilityForm.build_from_application(
        current_application,
      )
    end

    def update
      @training_with_a_disability_form = TrainingWithADisabilityForm.new(training_with_a_disability_params)
      @training_with_a_disability_review = TrainingWithADisabilityReviewPresenter.new(@training_with_a_disability_form)

      if @training_with_a_disability_form.save(current_application)
        render :show
      else
        render :edit
      end
    end

    def show
      training_with_a_disability_form = TrainingWithADisabilityForm.build_from_application(
        current_application,
      )
      @training_with_a_disability_review = TrainingWithADisabilityReviewPresenter.new(training_with_a_disability_form)
    end

  private

    def training_with_a_disability_params
      params.require(:candidate_interface_training_with_a_disability_form).permit(
        :disclose_disability, :disability_disclosure
      )
    end
  end
end
