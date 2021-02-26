module CandidateInterface
  class Gcse::TypeController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def edit
      @type_form = build_type_form
    end

    def update
      @type_form = build_type_form

      @type_form.set_attributes(qualification_params)

      if @type_form.save_base(current_candidate.current_application)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@type_form)
        render :edit
      end
    end

  private

    def build_type_form
      if current_qualification
        GcseQualificationTypeForm.build_from_qualification(current_qualification)
      else
        GcseQualificationTypeForm.new(
          subject: subject_param,
          level: ApplicationQualification.levels[:gcse],
        )
      end
    end

    def next_gcse_path
      if new_non_uk_qualification?
        candidate_interface_gcse_details_edit_institution_country_path
      elsif !@type_form.missing_qualification? && current_qualification.grade.nil?
        resolve_gcse_edit_path(@subject)
      else
        candidate_interface_gcse_review_path
      end
    end

    def qualification_params
      strip_whitespace params
        .require(:candidate_interface_gcse_qualification_type_form)
        .permit(:qualification_type, :other_uk_qualification_type, :missing_explanation, :non_uk_qualification_type)
    end

    def new_non_uk_qualification?
      current_qualification.qualification_type == 'non_uk' &&
        current_qualification.institution_country.nil?
    end
  end
end
