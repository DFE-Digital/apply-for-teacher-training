class BackfillHesaCodesForSexEthicityAndDisability < ActiveRecord::Migration[6.0]
  def change
    cycle_year = 2020
    CandidateInterface::HesaCodeBackfill.call(cycle_year)
  end
end
