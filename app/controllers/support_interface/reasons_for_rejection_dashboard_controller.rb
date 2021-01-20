module SupportInterface
  class ReasonsForRejectionDashboardController < SupportInterfaceController
    def dashboard
      sql_query = GetReasonsForRejectionFromApplicationChoices.new.count_sql(Date.today.beginning_of_month)
      @reasons_for_rejection_statistics = ActiveRecord::Base.connection.execute(sql_query).to_a
    end
  end
end
