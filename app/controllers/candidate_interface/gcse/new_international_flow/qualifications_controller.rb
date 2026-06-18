module CandidateInterface
  class Gcse::NewInternationalFlow::QualificationsController < Gcse::NewInternationalFlow::BaseController
    def new
      @equivalent_qualification_form = GcseEquivalentQualificationForm.build_from_qualification(current_qualification)
      @list_of_qualifications = @equivalent_qualifications.any?
    end

    def edit
      @equivalent_qualification_form = GcseEquivalentQualificationForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def create
      @equivalent_qualification_form = GcseEquivalentQualificationForm.new(equivalent_qualification_params)

      if @equivalent_qualification_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_new_grades_path
      else
        track_validation_error(@equivalent_qualification_form)
        render :new
      end
    end

    def update
      @equivalent_qualification_form = GcseEquivalentQualificationForm.new(equivalent_qualification_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @equivalent_qualification_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@equivalent_qualification_form)
        render :edit
      end
    end

  private

    def equivalent_qualification_params
      params
        .expect(candidate_interface_gcse_equivalent_qualification_form: %i[qualification non_structured_qualification])
    end
  end
end
