module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    before_action :set_application_choice_and_sub_navigation_items, except: %i[index]

    def index
      @page_state = ProviderApplicationsPageState.new(
        params: params,
        provider_user: current_provider_user,
      )

      application_choices = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )

      application_choices = FilterApplicationChoicesForProviders.call(
        application_choices: application_choices,
        filters: @page_state.applied_filters,
      )

      application_choices = ProviderInterface::SortApplicationChoices.call(
        application_choices: application_choices,
        sort_by: @page_state.sort_by,
      )

      @application_choices = application_choices.page(params[:page] || 1).per(15)
    end

    def show
      auth = ProviderAuthorisation.new(actor: current_provider_user)
      @provider_can_respond = auth.can_make_offer?(
        application_choice: @application_choice,
        course_option_id: @application_choice.offered_option.id,
      )

      @status_box_options = if @application_choice.offer? && @provider_can_respond
                              get_all_change_options @application_choice
                            else
                              {}
                            end
    end

    def notes
      @notes = @application_choice.notes.order('created_at DESC')
    end

    def new_note
      @new_note_form = ProviderInterface::NewNoteForm.new
    end

    def create_note
      @new_note_form = ProviderInterface::NewNoteForm.new new_note_params

      if @new_note_form.save
        flash[:success] = 'Note successfully added'
        redirect_to provider_interface_application_choice_notes_path(@application_choice)
      else
        render(action: :new_note)
      end
    end

    def timeline; end

    def emails
      if HostingEnvironment.sandbox_mode?
        @emails = Email.includes(:application_form)
          .where(application_form_id: @application_choice.application_form)
      else
        render_403
      end
    end

  private

    def available_providers
      current_provider_user.providers
    end

    def set_application_choice_and_sub_navigation_items
      @application_choice = get_application_choice
      @sub_navigation_items = get_sub_navigation_items
    end

    def get_application_choice
      GetApplicationChoicesForProviders.call(
        providers: available_providers,
      ).find(params[:application_choice_id])
    end

    def get_sub_navigation_items
      sub_navigation_items = [
        { name: 'Application', url: provider_interface_application_choice_path(@application_choice) },
      ]

      sub_navigation_items.push(
        { name: 'Notes', url: provider_interface_application_choice_notes_path(@application_choice) },
      )

      sub_navigation_items.push(
        { name: 'Timeline', url: provider_interface_application_choice_timeline_path(@application_choice) },
      )

      if HostingEnvironment.sandbox_mode?
        sub_navigation_items.push(
          { name: 'Emails (Sandbox only)', url: provider_interface_application_choice_emails_path(@application_choice) },
        )
      end

      sub_navigation_items
    end

    def get_all_change_options(application_choice)
      GetAllChangeOptionsFromOfferedOption.new(
        application_choice: application_choice,
        available_providers: available_providers,
      ).call
    end

    def new_note_params
      params.require(:provider_interface_new_note_form).permit(:subject, :message).merge \
        application_choice: @application_choice,
        provider_user: current_provider_user
    end
  end
end
