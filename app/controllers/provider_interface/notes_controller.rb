module ProviderInterface
  class NotesController < ProviderInterfaceController
    before_action :set_application_choice

    def index
      @provider_can_respond = current_provider_user.authorisation.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.current_course_option.id,
      )

      @notes = @application_choice.notes.order('created_at DESC')
    end

    def show
      @note = @application_choice.notes.find(params[:id])
    end

    def new
      @new_note_form = ProviderInterface::NewNoteForm.new
    end

    def create
      @new_note_form = ProviderInterface::NewNoteForm.new(note_params)

      if @new_note_form.save
        flash[:success] = 'Note successfully added'
        redirect_to provider_interface_application_choice_notes_path(@application_choice)
      else
        render(action: :new)
      end
    end

  private

    def note_params
      params.require(:provider_interface_new_note_form).permit(:message)
        .merge(application_choice: @application_choice, provider_user: current_provider_user)
    end
  end
end
