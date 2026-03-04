module CandidateInterface
  module EnglishProficiencies
    class NoQualificationDetailsController < SectionController
      def edit
        @no_qualification_details_form = CandidateInterface::EnglishProficiencies::NoQualificationDetailsForm.new.fill(english_proficiency)
      end

      def update
        @no_qualification_details_form = CandidateInterface::EnglishProficiencies::NoQualificationDetailsForm.new(
          no_qualification_details_params,
        )
        if @no_qualification_details_form.save
          redirect_to @no_qualification_details_form.next_path
        else
          track_validation_error(@no_qualification_details_form)
          render :edit
        end
      end

      private

      def english_proficiency
        @english_proficiency ||= current_application
          .english_proficiencies
          .where(qualification_status: %w[no_qualification degree_taught_in_english])
          .find(params[:english_proficiency_id])
      end

      def no_qualification_details_params
        strip_whitespace params
          .fetch(:candidate_interface_english_proficiencies_no_qualification_details_form, {})
          .permit(:declare_no_qualification_details, :no_qualification_details)
          .merge(application_form: current_application, english_proficiency:)
          .merge(return_to: params[:'return-to'])
      end
    end
  end
end
