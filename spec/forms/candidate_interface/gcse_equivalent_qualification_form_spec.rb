require 'rails_helper'

RSpec.describe CandidateInterface::GcseEquivalentQualificationForm do
  describe 'validations' do
    context 'when qualification is blank' do
      subject(:form) { described_class.new(qualification: nil) }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:qualification]).to include('Select a qualification')
      end
    end

    context 'when a structured qualification is selected' do
      subject(:form) do
        described_class.new(
          qualification: 'WASSCE (West African Senior School Certificate Examination)',
        )
      end

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end

    context 'when other is selected and no qualification is entered' do
      subject(:form) do
        described_class.new(
          qualification: 'other',
          non_structured_qualification: nil,
        )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:non_structured_qualification]).to include('Enter a qualification')
      end
    end

    context 'when other is selected and qualification is too short' do
      subject(:form) do
        described_class.new(
          qualification: 'other',
          non_structured_qualification: 'A',
        )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:non_structured_qualification]).to include('Qualification must be 2 characters or more')
      end
    end

    context 'when other is selected and qualification is valid' do
      subject(:form) do
        described_class.new(
          qualification: 'other',
          non_structured_qualification: 'My qualification',
        )
      end

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end
  end

  describe '.build_from_qualification' do
    let(:application_qualification) do
      build(
        :application_qualification,
        non_uk_qualification_type: qualification_type,
      )
    end

    context 'when qualification is in the structured list' do
      let(:qualification_type) do
        'WASSCE (West African Senior School Certificate Examination)'
      end

      it 'builds a structured form' do
        form = described_class.build_from_qualification(
          application_qualification,
          equivalent_qualifications: [qualification_type],
        )

        expect(form.qualification).to eq(qualification_type)
        expect(form.non_structured_qualification).to be_nil
      end
    end

    context 'when qualification is not in the structured list' do
      let(:qualification_type) { 'Custom qualification' }

      it 'builds an other form' do
        form = described_class.build_from_qualification(
          application_qualification,
          equivalent_qualifications: ['WASSCE (West African Senior School Certificate Examination)'],
        )

        expect(form.qualification).to eq('other')
        expect(form.non_structured_qualification).to eq('Custom qualification')
      end
    end

    context 'when qualification is blank' do
      let(:qualification_type) { nil }

      it 'returns empty values' do
        form = described_class.build_from_qualification(
          application_qualification,
          equivalent_qualifications: [],
        )

        expect(form.qualification).to be_nil
        expect(form.non_structured_qualification).to be_nil
      end
    end
  end

  describe '#save' do
    let(:application_qualification) { create(:application_qualification) }

    context 'when a structured qualification is selected' do
      subject(:form) do
        described_class.new(
          qualification: 'WASSCE (West African Senior School Certificate Examination)',
        )
      end

      it 'updates the qualification' do
        form.save(application_qualification)

        expect(application_qualification.reload.non_uk_qualification_type).to eq('WASSCE (West African Senior School Certificate Examination)')
      end
    end

    context 'when another qualification is entered' do
      subject(:form) do
        described_class.new(
          qualification: 'other',
          non_structured_qualification: 'My custom qualification',
        )
      end

      it 'updates the qualification' do
        form.save(application_qualification)

        expect(application_qualification.reload.non_uk_qualification_type).to eq('My custom qualification')
      end
    end

    context 'when the form is invalid' do
      subject(:form) do
        described_class.new(
          qualification: 'other',
          non_structured_qualification: nil,
        )
      end

      it 'returns false' do
        expect(form.save(application_qualification)).to be(false)
      end
    end
  end

  describe '#non_structured?' do
    context 'when qualification is other' do
      subject(:form) { described_class.new(qualification: 'other') }

      it 'returns true' do
        expect(form.non_structured?).to be(true)
      end
    end

    context 'when qualification is structured' do
      subject(:form) do
        described_class.new(
          qualification: 'WASSCE (West African Senior School Certificate Examination)',
        )
      end

      it 'returns false' do
        expect(form.non_structured?).to be(false)
      end
    end
  end

  describe '#resolved_qualification' do
    context 'when qualification is structured' do
      subject(:form) do
        described_class.new(
          qualification: 'WASSCE (West African Senior School Certificate Examination)',
        )
      end

      it 'returns the structured qualification' do
        expect(form.resolved_qualification).to eq('WASSCE (West African Senior School Certificate Examination)')
      end
    end

    context 'when qualification is other' do
      subject(:form) do
        described_class.new(
          qualification: 'other',
          non_structured_qualification: 'Custom qualification',
        )
      end

      it 'returns the custom qualification' do
        expect(form.resolved_qualification).to eq('Custom qualification')
      end
    end
  end
end
