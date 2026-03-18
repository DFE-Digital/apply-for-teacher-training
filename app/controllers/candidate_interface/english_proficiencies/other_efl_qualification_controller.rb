module CandidateInterface
  module EnglishProficiencies
    class OtherEflQualificationController < CandidateInterfaceController
      before_action :set_return_to

      def new
        @other_qualification_form = EnglishProficiencies::OtherEflQualificationForm.new(other_params).fill
      end

      def create
        @other_qualification_form = EnglishProficiencies::OtherEflQualificationForm.new(other_params)

        if @other_qualification_form.save
          redirect_to candidate_interface_english_proficiencies_review_path(@return_to[:params])
        else
          track_validation_error(@other_qualification_form)
          render :new
        end
      end

    private

      def english_proficiency
        @english_proficiency ||= current_application
                                   .english_proficiencies
                                   .find(params[:english_proficiency_id])
      end

      def other_params
        strip_whitespace params
          .fetch(:candidate_interface_english_proficiencies_other_efl_qualification_form, {})
          .permit(:name, :grade, :award_year)
          .merge(application_form: current_application, english_proficiency:)
      end

      def set_return_to
        return_path = if params[:return_to] == 'review'
                        candidate_interface_english_proficiencies_review_path
                      else
                        candidate_interface_english_proficiencies_type_path(english_proficiency, type: 'other')
                      end
        @return_to = return_to_after_edit(default: return_path)
      end
    end
  end
end
