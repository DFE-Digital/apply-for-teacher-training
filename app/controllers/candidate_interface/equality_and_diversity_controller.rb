module CandidateInterface
  class EqualityAndDiversityController < CandidateInterfaceController
    def start; end

    def edit_sex
      @sex = EqualityAndDiversity::SexForm.build_from_application(current_application)
    end

    def update_sex
      @sex = EqualityAndDiversity::SexForm.new(sex: sex_param)

      if @sex.save(current_application)
        redirect_to candidate_interface_review_equality_and_diversity_path
      else
        render :edit_sex
      end
    end

    def review; end

  private

    def sex_param
      params.dig(:candidate_interface_equality_and_diversity_sex_form, :sex)
    end
  end
end
