module CandidateInterface
  module EnglishProficiencies
    class StartController < CandidateInterfaceController
      def new
        @start_form = EnglishProficiencies::StartForm.new
      end

      def edit
        @start_form = EnglishProficiencies::StartForm.new.fill(current_application)
        @return_to = return_to_after_edit(default: candidate_interface_english_proficiencies_review_path)
      end

      def create
        @start_form = EnglishProficiencies::StartForm.new(start_params)
        if @start_form.save
          redirect_to @start_form.next_path
        else
          track_validation_error(@start_form)
          render :new
        end
      end

      def update
        @start_form = EnglishProficiencies::StartForm.new(start_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_proficiencies_review_path)

        if @start_form.save
          redirect_to @start_form.next_path
        else
          track_validation_error(@start_form)
          render :edit
        end
      end

    private

      def start_params
        strip_whitespace params
         .fetch(:candidate_interface_english_proficiencies_start_form, {})
         .permit(qualification_statuses: [])
         .merge(application_form: current_application)
         .merge(return_to: params[:'return-to'])
      end
    end
  end
end
