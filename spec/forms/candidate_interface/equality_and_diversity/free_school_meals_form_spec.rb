require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::FreeSchoolMealsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:free_school_meals) }
  end

  describe '.build_from_application' do
    it 'creates a form object with free school meals set to yes' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'free_school_meals' => 'yes' })

      form = described_class.build_from_application(application_form)

      expect(form.free_school_meals).to eq('yes')
    end

    it 'creates a form object with free school meals set to no' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'free_school_meals' => 'no' })

      form = described_class.build_from_application(application_form)

      expect(form.free_school_meals).to eq('no')
    end

    it 'creates a form object with free school meals set to I did not go to school in the UK' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'free_school_meals' => 'I did not go to school in the UK' })

      form = described_class.build_from_application(application_form)

      expect(form.free_school_meals).to eq('I did not go to school in the UK')
    end

    it 'creates a form object with free school meals set to I do not know' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'free_school_meals' => 'I do not know' })

      form = described_class.build_from_application(application_form)

      expect(form.free_school_meals).to eq('I do not know')
    end

    it 'creates a form object with free school meals set to Prefer not to say' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'free_school_meals' => 'Prefer not to say' })

      form = described_class.build_from_application(application_form)

      expect(form.free_school_meals).to eq('Prefer not to say')
    end
  end

  describe '.save' do
    let(:application_form) { create(:application_form) }

    context 'when free school meals is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when free school meals has a value' do
      it 'returns true' do
        form = described_class.new(free_school_meals: 'yes')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the equality and diversity information on the application form' do
        form = described_class.new(free_school_meals: 'no')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('free_school_meals' => 'no')
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male',
                                                                              'disabilities' => [],
                                                                              'ethnic_group' => 'Asian or Asian British',
                                                                              'ethnic_background' => 'Chinese' })

        form = described_class.new(free_school_meals: 'I do not know')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male', 'disabilities' => [], 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Chinese', 'free_school_meals' => 'I do not know',
        )
      end
    end
  end
end
