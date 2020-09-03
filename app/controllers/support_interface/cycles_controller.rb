module SupportInterface
  class CyclesController < SupportInterfaceController
    def switch_cycle_schedule
      SiteSetting.set(name: 'cycle_schedule', value: params.fetch(:cycle_schedule_name))
      flash[:success] = 'Cycle schedule updated'
      redirect_to support_interface_cycles_path
    end
  end
end
