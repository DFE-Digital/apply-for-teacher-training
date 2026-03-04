module CandidateInterface
  module EnglishProficiencies
    class TypeController < CandidateInterfaceController
      def new
        @type_form = EnglishProficiencies::TypeForm.new
        return_to = if current_application.english_proficiencies.has_qualification.present?
                      candidate_interface_english_proficiencies_review_path
                    else
                      candidate_interface_english_proficiencies_edit_start_path
                    end
        @return_to = return_to_after_edit(default: return_to)
      end

      def create
        @type_form = EnglishProficiencies::TypeForm.new(type_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_proficiencies_type_path)

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
           .merge(return_to: params[:'return-to'])
      end
    end
  end
end
