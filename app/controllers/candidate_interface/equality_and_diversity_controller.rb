module CandidateInterface
  class EqualityAndDiversityController < CandidateInterfaceController
    def start; end

    def edit_sex
      @sex = EqualityAndDiversity::SexForm.build_from_application(current_application)
    end

    def update_sex
      @sex = EqualityAndDiversity::SexForm.new(sex: sex_param)

      if @sex.save(current_application)
        if current_application.equality_and_diversity['disabilities'].nil?
          redirect_to candidate_interface_edit_equality_and_diversity_disability_status_path
        else
          redirect_to candidate_interface_review_equality_and_diversity_path
        end
      else
        render :edit_sex
      end
    end

    def edit_disability_status
      @disability_status = EqualityAndDiversity::DisabilityStatusForm.build_from_application(current_application)
    end

    def update_disability_status
      @disability_status = EqualityAndDiversity::DisabilityStatusForm.new(disability_status: disability_status_param)

      if @disability_status.save(current_application)
        if disability_status_param == 'no'
          redirect_to candidate_interface_edit_equality_and_diversity_ethnic_group_path
        else
          redirect_to candidate_interface_edit_equality_and_diversity_disabilities_path
        end
      else
        render :edit_disability_status
      end
    end

    def edit_disabilities
      @disabilities = EqualityAndDiversity::DisabilitiesForm.build_from_application(current_application)
    end

    def update_disabilities
      @disabilities = EqualityAndDiversity::DisabilitiesForm.new(disabilties_params)

      if @disabilities.save(current_application)
        redirect_to candidate_interface_review_equality_and_diversity_path
      else
        render :edit_disabilities
      end
    end

    def edit_ethnic_group
      @ethnic_group = EqualityAndDiversity::EthnicGroupForm.build_from_application(current_application)
    end

    def update_ethnic_group
      @ethnic_group = EqualityAndDiversity::EthnicGroupForm.new(ethnic_group: ethnic_group_param)

      if @ethnic_group.save(current_application)
        redirect_to candidate_interface_review_equality_and_diversity_path
      else
        render :edit_ethnic_group
      end
    end

    def review; end

  private

    def sex_param
      params.dig(:candidate_interface_equality_and_diversity_sex_form, :sex)
    end

    def disability_status_param
      params.dig(:candidate_interface_equality_and_diversity_disability_status_form, :disability_status)
    end

    def disabilties_params
      params.require(:candidate_interface_equality_and_diversity_disabilities_form).permit(:other_disability, disabilities: [])
    end

    def ethnic_group_param
      params.dig(:candidate_interface_equality_and_diversity_ethnic_group_form, :ethnic_group)
    end
  end
end
