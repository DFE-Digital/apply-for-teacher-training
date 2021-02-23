require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm, type: :model do
  describe '.build_from_application' do
    context 'when ethnic background is listed' do
      it 'creates an object with ethnic background' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Chinese' })

        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.build_from_application(application_form)

        expect(form.ethnic_background).to eq('Chinese')
        expect(form.other_background).to eq(nil)
      end
    end

    context 'when ethnic background is unlisted' do
      it 'creates an object with ethnic background set to another and other background is ethnic background' do
        application_form = build_stubbed(:application_form,
                                         equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Unlisted ethnic background' })

        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.build_from_application(application_form)

        expect(form.ethnic_background).to eq('Another Asian background')
        expect(form.other_background).to eq('Unlisted ethnic background')
      end
    end

    context 'when ethnic background is another background' do
      it 'creates an object with ethnic background' do
        application_form = build_stubbed(:application_form,
                                         equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Another Asian background' })

        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.build_from_application(application_form)

        expect(form.ethnic_background).to eq('Another Asian background')
        expect(form.other_background).to eq(nil)
      end
    end

    context 'when ethnic background is not present' do
      it 'creates an object with empty ethnic background' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => nil })

        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.build_from_application(application_form)

        expect(form.ethnic_background).to eq(nil)
        expect(form.other_background).to eq(nil)
      end
    end
  end

  describe '#save' do
    let(:application_form) { build(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British' }) }

    context 'when ethnic background field is blank' do
      it 'returns false' do
        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when ethnic background is listed' do
      it 'returns true' do
        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.new(ethnic_background: 'Bangladeshi')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the application form with the ethnic background value' do
        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.new(ethnic_background: 'Bangladeshi')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Bangladeshi',
          'hesa_ethnicity' => '33',
        )
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male', 'ethnic_group' => 'Asian or Asian British' })
        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.new(ethnic_background: 'Bangladeshi')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Bangladeshi',
          'hesa_ethnicity' => '33',
        )
      end
    end

    context 'when ethnic background is another background' do
      it 'updates the application form with the other background value if other background provided' do
        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.new(ethnic_background: 'Another Asian background', other_background: 'Unlisted ethnic background')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Unlisted ethnic background',
          'hesa_ethnicity' => '39',
        )
      end

      it 'updates the application form with the ethnic background value if other background is not provided' do
        form = CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm.new(ethnic_background: 'Another Asian background', other_background: nil)

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Another Asian background',
          'hesa_ethnicity' => '39',
        )
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ethnic_background) }
  end
end
