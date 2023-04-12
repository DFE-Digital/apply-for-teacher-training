module SupportInterface
  module ApplicationForms
    class OtherQualificationsController < SupportInterfaceController
      def edit_award_year
        @qualification_award_year_form = EditOtherQualificationAwardYearForm.new(
          ApplicationQualification.find(params[:qualification_id]),
        )
      end

      def update_award_year
        @qualification_award_year_form = EditOtherQualificationAwardYearForm.new(
          ApplicationQualification.find(params[:qualification_id]),
        )

        @qualification_award_year_form.assign_attributes(edit_award_year_params)
        if @qualification_award_year_form.valid?
          @qualification_award_year_form.save!
          flash[:success] = 'Qualification award year updated'
          redirect_to support_interface_application_form_path(@qualification_award_year_form.application_form)
        else
          render :edit_award_year
        end
      end

      def edit_grade
        @qualification_grade_form = EditOtherQualificationGradeForm.new(
          ApplicationQualification.find(params[:qualification_id]),
        )
      end

      def update_grade
        @qualification_grade_form = EditOtherQualificationGradeForm.new(
          ApplicationQualification.find(params[:qualification_id]),
        )

        @qualification_grade_form.assign_attributes(edit_grade_params)
        if @qualification_grade_form.valid?
          @qualification_grade_form.save!
          flash[:success] = 'Qualification grade updated'
          redirect_to support_interface_application_form_path(@qualification_grade_form.application_form)
        else
          render :edit_grade
        end
      end

    private

      def edit_award_year_params
        params.require(
          :support_interface_application_forms_edit_other_qualification_award_year_form,
        ).permit(:award_year, :audit_comment)
      end

      def edit_grade_params
        params.require(
          :support_interface_application_forms_edit_other_qualification_grade_form,
        ).permit(:grade, :audit_comment)
      end
    end
  end
end
