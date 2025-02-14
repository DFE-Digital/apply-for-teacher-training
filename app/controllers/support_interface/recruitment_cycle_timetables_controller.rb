module SupportInterface
  class RecruitmentCycleTimetablesController < SupportInterfaceController
    def index
      @timetable_presenter = SupportInterface::RecruitmentCycleTimetablePresenter.new(Current.cycle_timetable)
    end

    def edit
      timetable = RecruitmentCycleTimetable.find_by!(recruitment_cycle_year: recruitment_cycle_year_params)
      @cycle_switcher_form = SupportInterface::CycleSwitcherForm.build_from_timetable(timetable)
    end

    def update
      timetable = RecruitmentCycleTimetable.find_by!(recruitment_cycle_year: recruitment_cycle_year_params)
      @cycle_switcher_form = SupportInterface::CycleSwitcherForm.build_from_form(
        recruitment_cycle_timetable_params, timetable:
      )

      if @cycle_switcher_form.persist
        flash[:success] = I18n.t(
          'support_interface.recruitment_cycle_timetables.update.success_message',
        )

        redirect_to support_interface_recruitment_cycle_timetables_path
      else
        render :edit
      end
    end

    def reset
      # Reseeding is temporary. We'll hit the production API for these when it is live
      DataMigrations::AddAllRecruitmentCycleTimetablesToDatabase.new.change
      flash[:success] = I18n.t('support_interface.recruitment_cycle_timetables.reset.success_message')
      redirect_to support_interface_recruitment_cycle_timetables_path
    end

  private

    def recruitment_cycle_year_params
      params.expect(:recruitment_cycle_year)
    end

    def recruitment_cycle_timetable_params
      params.expect(
        support_interface_cycle_switcher_form: %i[
          find_opens_at
          apply_opens_at
          apply_deadline_at
          reject_by_default_at
          decline_by_default_at
          find_closes_at
        ],
      )
    end
  end
end
