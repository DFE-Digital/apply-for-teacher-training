module CandidateInterface
  module EnglishProficiencies
    class TypeController < CandidateInterfaceController
      before_action :set_return_to

      def new
        @type_form = EnglishProficiencies::TypeForm.new(type_params).fill(params[:type])
      end

      def create
        @type_form = EnglishProficiencies::TypeForm.new(type_params)

        if @type_form.save
          redirect_to @type_form.next_path
        else
          track_validation_error(@type_form)
          render :new
        end
      end

    private

      def type_params
        strip_whitespace params
           .fetch(:candidate_interface_english_proficiencies_type_form, {})
           .permit(:type)
           .merge(english_proficiency:)
           .merge(return_to: params[:'return-to'])
      end

      def english_proficiency
        @english_proficiency ||= current_application
                                   .english_proficiencies
                                   .find_by(id: params[:english_proficiency_id]) ||
                                 current_application.english_proficiency
      end

      def set_return_to
        return_path = if params[:return_to] == 'review'
                        candidate_interface_english_proficiencies_review_path
                      else
                        candidate_interface_english_proficiencies_edit_start_path(english_proficiency)
                      end
        @return_to = return_to_after_edit(default: return_path)
      end
    end
  end
end
