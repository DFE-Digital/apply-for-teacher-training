module CandidateInterface
  class EqualityAndDiversityController < CandidateInterfaceController
    before_action :redirect_to_review_unless_ready_to_submit

    def start
      @choice_form = EqualityAndDiversity::ChoiceForm.new
    end

    def choice
      @choice_form = EqualityAndDiversity::ChoiceForm.new(choice: choice_param)
      render :start and return unless @choice_form.valid?

      entrypoint_path =
        if current_application.equality_and_diversity_answers_provided?
          candidate_interface_review_equality_and_diversity_path
        else
          candidate_interface_edit_equality_and_diversity_sex_path
        end

      if @choice_form.choice == 'yes'
        redirect_to entrypoint_path
      else
        redirect_to candidate_interface_application_submit_show_path
      end
    end

    def edit_sex
      @sex = EqualityAndDiversity::SexForm.build_from_application(current_application)
    end

    def update_sex
      @sex = EqualityAndDiversity::SexForm.new(sex: sex_param)

      if @sex.save(current_application)
        if current_application.equality_and_diversity['disabilities'].nil?
          redirect_to candidate_interface_edit_equality_and_diversity_disabilities_path
        else
          redirect_to candidate_interface_review_equality_and_diversity_path
        end
      else
        render :edit_sex
      end
    end

    def edit_disabilities
      @disabilities = EqualityAndDiversity::DisabilitiesForm.build_from_application(current_application)
    end

    def update_disabilities
      @disabilities = EqualityAndDiversity::DisabilitiesForm.new(disabilities_params)

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

    def choice_param
      params.dig(:candidate_interface_equality_and_diversity_choice_form, :choice)
    end

    def sex_param
      params.dig(:candidate_interface_equality_and_diversity_sex_form, :sex)
    end

    def disability_status_param
      params.dig(:candidate_interface_equality_and_diversity_disability_status_form, :disability_status)
    end

    def disabilities_params
      params.require(:candidate_interface_equality_and_diversity_disabilities_form).permit(:other_disability, disabilities: []).tap do |dp|
        dp.delete(:disabilities) if dp[:disabilities] == ['']
      end
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
