module CandidateInterface
  class Gcse::English::GradeController < Gcse::BaseController
    def new
      @gcse_grade_form = english_gcse_grade_form
      @qualification_type = gcse_english_qualification.qualification_type
      set_previous_path

      render view_path
    end

    def edit
      @gcse_grade_form = english_gcse_grade_form
      @qualification_type = gcse_english_qualification.qualification_type
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      render view_path(update_path: true)
    end

    def create
      @qualification_type = gcse_english_qualification.qualification_type
      @gcse_grade_form = english_gcse_grade_form.assign_values(english_details_params)

      if @gcse_grade_form.save
        redirect_to candidate_interface_gcse_details_new_year_path(@subject)
      else
        set_previous_path
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

    def update
      @qualification_type = gcse_english_qualification.qualification_type
      @gcse_grade_form = english_gcse_grade_form.assign_values(english_details_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      if @gcse_grade_form.save
        if current_qualification.failed_required_gcse?
          redirect_to candidate_interface_gcse_details_edit_grade_explanation_path(@subject)
        else
          redirect_to candidate_interface_gcse_review_path(@subject)
        end
      else
        track_validation_error(@gcse_grade_form)
        render view_path(update_path: true)
      end
    end

  private

    def english_details_params
      strip_whitespace params
        .expect(candidate_interface_english_gcse_grade_form: [
          :english_single_award,
          :grade_english_single,
          :english_double_award,
          :grade_english_double,
          :english_language,
          :grade_english_language,
          :english_literature,
          :grade_english_literature,
          :english_studies_single_award,
          :grade_english_studies_single,
          :english_studies_double_award,
          :grade_english_studies_double,
          :other_english_gcse,
          :other_english_gcse_name,
          :grade_other_english_gcse,
          :grade,
          :other_grade,
          english_gcses: [],
        ])
    end

    def view_path(update_path: false)
      if gcse_qualification?
        if update_path
          'candidate_interface/gcse/english/grade/multiple_gcse_edit'
        else
          'candidate_interface/gcse/english/grade/multiple_gcse_new'
        end
      elsif update_path
        'candidate_interface/gcse/english/grade/edit'
      else
        'candidate_interface/gcse/english/grade/new'
      end
    end

    def gcse_qualification?
      gcse_english_qualification.qualification_type == 'gcse'
    end

    def gcse_english_qualification
      @gcse_english_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def english_gcse_grade_form
      @english_gcse_grade_form ||= EnglishGcseGradeForm.build_from_qualification(gcse_english_qualification)
    end

    def set_subject
      @subject = 'english'
    end

    def set_previous_path
      @previous_path = if current_qualification.non_uk_qualification_type.present?
                         candidate_interface_gcse_details_new_enic_path(@subject)
                       else
                         candidate_interface_gcse_details_new_type_path(@subject)
                       end
    end
  end
end
