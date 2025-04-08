require 'rails_helper'

RSpec.describe SafeChoiceUpdateValidator do
  before do
    RequestStore.store[:allow_unsafe_application_choice_touches] = false

    stub_const('Record', Class.new).class_eval do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :application_form
      # rubocop:disable RSpec/DescribedClass
      validates_with SafeChoiceUpdateValidator
      # rubocop:enable RSpec/DescribedClass
    end
  end

  context 'when choices are safe to touch' do
    it 'does not add an error' do
      record = Record.new
      record.application_form = create(:application_form)

      described_class.new.validate(record)

      expect(record).to be_valid
      expect(record.errors).to be_blank
    end
  end

  context 'when choices are not safe to touch' do
    it 'does add an error' do
      record = Record.new
      record.application_form = create(
        :application_form,
        recruitment_cycle_year: current_year - 1,
      )

      described_class.new.validate(record)

      expect(record).not_to be_valid
      expect(record.errors[:base]).to contain_exactly(
        "The application must be in the current cycle #{current_year}",
      )
    end
  end
end
