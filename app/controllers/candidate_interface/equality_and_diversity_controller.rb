module CandidateInterface
  class EqualityAndDiversityController < CandidateInterfaceController
    before_action :redirect_to_application_review, unless: :ready_to_submit?
    before_action :set_review_back_link
    before_action :check_that_candidate_should_be_asked_about_free_school_meals, only: [:edit_free_school_meals]

    def start
      redirect_to candidate_interface_review_equality_and_diversity_path if applying_again? && equality_and_diversity_already_completed?
    end

    def edit_sex
      @sex = EqualityAndDiversity::SexForm.build_from_application(current_application)
    end

    def update_sex
      @sex = EqualityAndDiversity::SexForm.new(sex: sex_param)

      if @sex.save(current_application)
        redirect_to next_equality_and_diversity_page(candidate_interface_edit_equality_and_diversity_disabilities_path)
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
        redirect_to next_equality_and_diversity_page(candidate_interface_edit_equality_and_diversity_ethnic_group_path)
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
          redirect_to next_equality_and_diversity_page(free_school_meals_or_review(current_application))
        else
          redirect_to candidate_interface_edit_equality_and_diversity_ethnic_background_path(return_to: params.fetch(:return_to, nil))
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
        redirect_to next_equality_and_diversity_page(free_school_meals_or_review(current_application))
      else
        render :edit_ethnic_background
      end
    end

    def edit_free_school_meals
      @free_school_meals = EqualityAndDiversity::FreeSchoolMealsForm.build_from_application(current_application)
      @back_link = return_to_path || candidate_interface_edit_equality_and_diversity_ethnic_group_path
    end

    def update_free_school_meals
      @free_school_meals = EqualityAndDiversity::FreeSchoolMealsForm.new(free_school_meals: free_school_meals_param)

      if @free_school_meals.save(current_application)
        redirect_to candidate_interface_review_equality_and_diversity_path
      else
        render :edit_free_school_meals
      end
    end

    def review; end

  private

    def sex_param
      params.dig(:candidate_interface_equality_and_diversity_sex_form, :sex)
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

    def free_school_meals_param
      params.dig(:candidate_interface_equality_and_diversity_free_school_meals_form, :free_school_meals)
    end

    def free_school_meals_or_review(application)
      if application.ask_about_free_school_meals?
        candidate_interface_edit_equality_and_diversity_free_school_meals_path
      else
        candidate_interface_review_equality_and_diversity_path
      end
    end

    def check_that_candidate_should_be_asked_about_free_school_meals
      redirect_to candidate_interface_review_equality_and_diversity_path unless current_application.ask_about_free_school_meals?
    end

    def next_equality_and_diversity_page(next_page)
      if params[:return_to] == 'review'
        candidate_interface_review_equality_and_diversity_path
      else
        next_page
      end
    end

    def return_to_path
      return false if current_application.equality_and_diversity.nil?

      candidate_interface_edit_equality_and_diversity_ethnic_background_path if current_application.equality_and_diversity['ethnic_background'].present?
    end

    def redirect_to_application_review
      redirect_to candidate_interface_application_submit_show_path
    end

    def ready_to_submit?
      @ready_to_submit ||= CandidateInterface::ApplicationFormPresenter.new(current_application).ready_to_submit?
    end

    def applying_again?
      current_application.previous_application_form&.current_recruitment_cycle?
    end

    def equality_and_diversity_already_completed?
      current_application.equality_and_diversity_answers_provided?
    end

    def set_review_back_link
      @review_back_link = candidate_interface_review_equality_and_diversity_path if params[:return_to] == 'review'
    end
  end
end
