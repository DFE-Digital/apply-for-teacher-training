module CandidateInterface
  module EnglishProficiencies
    class StartController < CandidateInterfaceController
      before_action :set_return_to, only: %i[edit update]
      def new
        @start_form = EnglishProficiencies::StartForm.new
      end

      def edit
        @start_form = EnglishProficiencies::StartForm.new.fill(current_application, english_proficiency)
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

      def set_return_to
        return_path = if english_proficiency.draft
                        application_form_path
                      else
                        candidate_interface_english_proficiencies_review_path
                      end
        @return_to = return_to_after_edit(default: return_path)
      end

      def english_proficiency
        @english_proficiency ||= current_application
                                   .english_proficiencies
                                   .find(params[:english_proficiency_id]) || current_application.english_proficiency
      end
    end
  end
end
