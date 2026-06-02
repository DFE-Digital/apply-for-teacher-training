require 'rails_helper'

RSpec.describe DataMigrations::NormalizeNamesOnApplicationForm do
  describe '#change' do
    let!(:application_form) do
      create(:application_form,
             recruitment_cycle_year: 2026,
             first_name: ' John ',
             last_name: ' Doe ')
    end

    it 'strips leading and trailing whitespace from first_name and last_name' do
      described_class.new.change

      application_form.reload
      expect(application_form.first_name).to eq('John')
      expect(application_form.last_name).to eq('Doe')
    end

    context 'when the application is outside the recruitment_cycle_year scope' do
      let!(:in_scope_form) do
        create(:application_form,
               recruitment_cycle_year: 2026,
               first_name: ' John ',
               last_name: ' Doe ')
      end

      let!(:out_of_scope_form) do
        create(:application_form,
               recruitment_cycle_year: 2024,
               first_name: '  Alice  ',
               last_name: '  Jones  ')
      end

      it 'does not modify applications from other recruitment cycles' do
        original_attrs = out_of_scope_form.attributes.slice('first_name', 'last_name', 'updated_at')

        described_class.new.change

        out_of_scope_form.reload
        expect(out_of_scope_form.attributes.slice('first_name', 'last_name', 'updated_at'))
          .to eq(original_attrs)
      end
    end

    context 'when names are already normalized' do
      let!(:application_form) do
        create(:application_form,
               recruitment_cycle_year: 2026,
               first_name: 'Jane',
               last_name: 'Smith')
      end

      it 'does not modify applications' do
        original_attrs = application_form.attributes.slice('first_name', 'last_name', 'updated_at')

        described_class.new.change

        application_form.reload
        expect(application_form.attributes.slice('first_name', 'last_name', 'updated_at'))
          .to eq(original_attrs)
      end
    end

    context 'when some forms are normalized and some are not' do
      let!(:normalized_form) do
        create(:application_form,
               recruitment_cycle_year: 2026,
               first_name: 'Jane',
               last_name: 'Smith')
      end

      let!(:unnormalized_form) do
        create(:application_form,
               recruitment_cycle_year: 2026,
               first_name: ' John ',
               last_name: ' Doe ')
      end

      it 'only updates forms with unnormalized names' do
        original_attrs = normalized_form.attributes.slice('first_name', 'last_name', 'updated_at')

        described_class.new.change

        normalized_form.reload
        unnormalized_form.reload

        expect(normalized_form.attributes.slice('first_name', 'last_name', 'updated_at'))
          .to eq(original_attrs)

        expect(unnormalized_form.first_name).to eq('John')
        expect(unnormalized_form.last_name).to eq('Doe')
      end
    end
  end
end
