module CandidateInterface
  class EqualityAndDiversityController < SectionController
    before_action :set_review_back_link
    before_action :check_that_candidate_should_be_asked_about_free_school_meals, only: [:edit_free_school_meals]

    def start
      if equality_and_diversity_already_completed?
        redirect_to candidate_interface_review_equality_and_diversity_path
      else
        redirect_to candidate_interface_edit_equality_and_diversity_sex_path
      end
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

    def review
      @section_complete_form = EqualityAndDiversityCompleteForm.new(completed: current_application.equality_and_diversity_completed)
    end

    def complete
      @section_complete_form = EqualityAndDiversityCompleteForm.new(form_params.merge(current_application:))

      if @section_complete_form.save(current_application, :equality_and_diversity_completed)
        if current_application.meets_conditions_for_adviser_interruption? && ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed)
          redirect_to candidate_interface_adviser_sign_ups_interruption_path(@current_application.id)
        else
          redirect_to_candidate_root
        end
      else
        track_validation_error(@section_complete_form)
        render :review
      end
    end

  private

    def sex_param
      params.dig(:candidate_interface_equality_and_diversity_sex_form, :sex)
    end

    def disabilities_params
      params.expect(candidate_interface_equality_and_diversity_disabilities_form: [:other_disability, disabilities: []]).tap do |dp|
        dp.delete(:disabilities) if dp[:disabilities] == ['']
      end
    end

    def ethnic_group_param
      params.dig(:candidate_interface_equality_and_diversity_ethnic_group_form, :ethnic_group)
    end

    def ethnic_background_param
      params.expect(candidate_interface_equality_and_diversity_ethnic_background_form: %i[ethnic_background other_background])
    end

    def free_school_meals_param
      params.dig(:candidate_interface_equality_and_diversity_free_school_meals_form, :free_school_meals)
    end

    def form_params
      strip_whitespace params.fetch(:candidate_interface_equality_and_diversity_complete_form, {}).permit(:completed)
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

    def equality_and_diversity_already_completed?
      current_application.equality_and_diversity_answers_provided?
    end

    def set_review_back_link
      @review_back_link = if params[:return_to] == 'review'
                            candidate_interface_review_equality_and_diversity_path
                          end
    end
  end
end
