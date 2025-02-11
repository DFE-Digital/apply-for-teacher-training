require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::EthnicBackgroundForm, type: :model do
  describe '.build_from_application' do
    context 'when ethnic background is listed' do
      it 'creates an object with ethnic background' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Chinese' })

        form = described_class.build_from_application(application_form)

        expect(form.ethnic_background).to eq('Chinese')
        expect(form.other_background).to be_nil
      end
    end

    context 'when ethnic background is unlisted' do
      it 'creates an object with ethnic background set to another and other background is ethnic background' do
        application_form = build_stubbed(:application_form,
                                         equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Unlisted ethnic background' })

        form = described_class.build_from_application(application_form)

        expect(form.ethnic_background).to eq('Another Asian background')
        expect(form.other_background).to eq('Unlisted ethnic background')
      end
    end

    context 'when ethnic background is another background' do
      it 'creates an object with ethnic background' do
        application_form = build_stubbed(:application_form,
                                         equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => 'Another Asian background' })

        form = described_class.build_from_application(application_form)

        expect(form.ethnic_background).to eq('Another Asian background')
        expect(form.other_background).to be_nil
      end
    end

    context 'when ethnic background is not present' do
      it 'creates an object with empty ethnic background' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'ethnic_background' => nil })

        form = described_class.build_from_application(application_form)

        expect(form.ethnic_background).to be_nil
        expect(form.other_background).to be_nil
      end
    end
  end

  describe '#save' do
    let(:application_form) { build(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British' }) }

    context 'when ethnic background field is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when ethnic background is listed' do
      it 'returns true' do
        form = described_class.new(ethnic_background: 'Bangladeshi')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the application form with the ethnic background value' do
        form = described_class.new(ethnic_background: 'Bangladeshi')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Bangladeshi',
          'hesa_ethnicity' => '100',
        )
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male', 'ethnic_group' => 'Asian or Asian British' })
        form = described_class.new(ethnic_background: 'Bangladeshi')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Bangladeshi',
          'hesa_ethnicity' => '100',
        )
      end
    end

    context 'when ethnic background is another background' do
      it 'updates the application form with the other background value if other background provided' do
        form = described_class.new(ethnic_background: 'Another Asian background', other_background: 'Unlisted ethnic background')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Unlisted ethnic background',
          'hesa_ethnicity' => '119',
        )
      end

      it 'updates the application form with the ethnic background value if other background is not provided' do
        form = described_class.new(ethnic_background: 'Another Asian background', other_background: nil)

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Another Asian background',
          'hesa_ethnicity' => '119',
        )
      end
    end

    context 'regression other white ethnicity' do
      let(:application_form) { build(:application_form, equality_and_diversity: { 'ethnic_group' => 'White' }) }

      it 'updates the application form with the white ethnic background value if other background is not provided' do
        form = described_class.new(ethnic_background: 'Another White background', other_background: nil)

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_group' => 'White',
          'ethnic_background' => 'Another White background',
          'hesa_ethnicity' => '179',
        )
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ethnic_background) }
  end

  describe '.listed_ethnic_background?' do
    it 'returns true if the group and background are in the ethnic backgrounds' do
      result = described_class.listed_ethnic_background?('Another ethnic group', 'Arab')
      expect(result).to be_truthy
    end

    it 'returns false if the group and background are not the ethnic backgrounds' do
      result = described_class.listed_ethnic_background?('Another ethnic group', 'Another ethnic group')
      expect(result).to be_falsey
    end

    it 'returns false if the group does not exist' do
      result = described_class.listed_ethnic_background?('wrong group', '')
      expect(result).to be_falsey
    end
  end
end
