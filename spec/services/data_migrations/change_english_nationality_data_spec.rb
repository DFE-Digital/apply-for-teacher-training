require 'rails_helper'

RSpec.describe DataMigrations::ChangeEnglishNationalityData do
  context 'old country nationalities' do
    %w[English Scottish Welsh].each do |nationality|
      it "changes #{nationality} first nationality to British" do
        application_form = create(:application_form, :minimum_info, first_nationality: nationality, recruitment_cycle_year: 2022)

        described_class.new.change

        expect(application_form.reload.first_nationality).to eq('British')
      end
    end
  end
end
