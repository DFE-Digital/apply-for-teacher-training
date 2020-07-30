module CandidateInterface
  class EqualityAndDiversityController < CandidateInterfaceController
    before_action :redirect_to_review_unless_ready_to_submit

    def start
      if current_application.submissions_closed?
        flash[:warning] = 'New applications are now closed for 2020'
        redirect_to candidate_interface_application_complete_path and return
      end

      entrypoint_path =
        if current_application.equality_and_diversity_answers_provided?
          candidate_interface_review_equality_and_diversity_path
        else
          candidate_interface_edit_equality_and_diversity_sex_path
        end

      render :start, locals: { entrypoint_path: entrypoint_path }
    end

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
        if disability_status_param == 'no' || disability_status_param == 'Prefer not to say'
          if current_application.equality_and_diversity['ethnic_group'].nil?
            redirect_to candidate_interface_edit_equality_and_diversity_ethnic_group_path
          else
            redirect_to candidate_interface_review_equality_and_diversity_path
          end
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
        if current_application.equality_and_diversity['ethnic_group'].nil?
          redirect_to candidate_interface_edit_equality_and_diversity_ethnic_group_path
        else
          redirect_to candidate_interface_review_equality_and_diversity_path
        end
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
        if ethnic_group_param == 'Prefer not to say'
          redirect_to candidate_interface_review_equality_and_diversity_path
        else
          redirect_to candidate_interface_edit_equality_and_diversity_ethnic_background_path
        end
      else
        render :edit_ethnic_group
      end
    end

    def edit_ethnic_background
      @ethnic_background = EqualityAndDiversity::EthnicBackgroundForm.build_from_application(current_application)
      @ethnic_group = current_application.equality_and_diversity['ethnic_group']
    end

    def update_ethnic_background
      @ethnic_background = EqualityAndDiversity::EthnicBackgroundForm.new(ethnic_background_param)
      @ethnic_group = current_application.equality_and_diversity['ethnic_group']

      if @ethnic_background.save(current_application)
        redirect_to candidate_interface_review_equality_and_diversity_path
      else
        render :edit_ethnic_background
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

    def ethnic_background_param
      params.require(:candidate_interface_equality_and_diversity_ethnic_background_form).permit(:ethnic_background, :other_background)
    end

    def redirect_to_review_unless_ready_to_submit
      redirect_to candidate_interface_application_submit_show_path unless ready_to_submit?
    end

    def ready_to_submit?
      @ready_to_submit ||= CandidateInterface::ApplicationFormPresenter.new(current_application).ready_to_submit?
    end
  end
end
