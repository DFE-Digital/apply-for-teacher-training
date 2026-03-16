require 'rails_helper'

RSpec.describe CandidateInterface::EnglishProficiencies::StartForm, type: :model do
  before do
    Feature.find_or_create_by(name: 'application_form_has_many_english_proficiencies', active: true)
  end

  after do
    FeatureFlag.deactivate(:application_form_has_many_english_proficiencies)
  end

  let(:valid_form) do
    described_class.new(
      qualification_statuses:,
    )
  end
  let(:qualification_statuses) { ['has_qualification'] }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_form).to be_valid
    end

    context 'when the qualification status is "no_qualification"' do
      let(:qualification_statuses) { ['no_qualification'] }

      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end

    context 'when the qualification status is "qualification_not_needed"' do
      let(:qualification_statuses) { ['qualification_not_needed'] }

      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end

    context 'when the qualification status is "degree_taught_in_english"' do
      let(:qualification_statuses) { ['degree_taught_in_english'] }

      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end

    it 'is invalid if missing any required attributes' do
      form = valid_form.tap { |f| f.qualification_statuses = nil }

      expect(form).not_to be_valid
      expect(
        form.errors.full_messages,
      ).to include('Qualification statuses Have you done an English as a foreign language assessment?')
    end

    it 'is invalid if qualification status is not valid' do
      form = valid_form.tap { |f| f.qualification_statuses = ['bbbb'] }

      expect(form).not_to be_valid
      expect(
        form.errors.full_messages,
      ).to eq  ['Qualification statuses Have you done an English as a foreign language assessment?']
    end
  end

  describe '#save' do
    it 'raises an error if no application_form present' do
      expect { valid_form.save }.to raise_error(
        CandidateInterface::EnglishProficiencies::MissingApplicationFormError,
      )
    end

    it 'returns false if not valid' do
      valid_form.qualification_statuses = nil

      expect(valid_form.save).to be false
    end

    context 'when attributes are valid' do
      let(:valid_form) do
        described_class.new(qualification_statuses:)
      end
      let(:qualification_statuses) { ['has_qualification'] }

      context 'when qualification_status is "has_qualification"' do
        let(:application_form) { create(:application_form) }

        it 'creates a draft english proficiency' do
          valid_form.application_form = application_form
          expect{ valid_form.save }.to change { application_form.english_proficiencies.count }.by(1)
          english_proficiency = application_form.english_proficiencies.last
          expect(english_proficiency.draft).to be(true)
          expect(english_proficiency.has_qualification).to be(true)
          expect(english_proficiency.degree_taught_in_english).to be(false)
          expect(english_proficiency.qualification_not_needed).to be(false)
          expect(english_proficiency.no_qualification).to be(false)
          expect(
            english_proficiency.qualification_statuses,
          ).to contain_exactly('has_qualification')
        end
      end

      context 'when qualification_status is "degree_taught_in_english"' do
        let(:application_form) { create(:application_form) }
        let(:qualification_statuses) { ['degree_taught_in_english'] }

        it 'creates a draft english proficiency' do
          valid_form.application_form = application_form
          expect{ valid_form.save }.to change { application_form.english_proficiencies.count }.by(1)
          english_proficiency = application_form.english_proficiencies.last
          expect(english_proficiency.draft).to be(true)
          expect(english_proficiency.has_qualification).to be(false)
          expect(english_proficiency.degree_taught_in_english).to be(true)
          expect(english_proficiency.qualification_not_needed).to be(false)
          expect(english_proficiency.no_qualification).to be(false)
          expect(
            english_proficiency.qualification_statuses,
            ).to contain_exactly('degree_taught_in_english')
        end
      end

      context 'when qualification_status is "qualification_not_needed"' do
        let(:application_form) { create(:application_form) }
        let(:qualification_statuses) { ['qualification_not_needed'] }

        it 'creates a published english proficiency' do
          valid_form.application_form = application_form
          expect{ valid_form.save }.to change { application_form.english_proficiencies.count }.by(1)
          english_proficiency = application_form.english_proficiencies.last
          expect(english_proficiency.draft).to be(false)
          expect(english_proficiency.has_qualification).to be(false)
          expect(english_proficiency.degree_taught_in_english).to be(false)
          expect(english_proficiency.qualification_not_needed).to be(true)
          expect(english_proficiency.no_qualification).to be(false)
          expect(
            english_proficiency.qualification_statuses,
            ).to contain_exactly('qualification_not_needed')
        end
      end

      context 'when qualification_status is "no_qualification"' do
        let(:application_form) { create(:application_form) }
        let(:qualification_statuses) { ['no_qualification'] }

        it 'creates a draft english proficiency' do
          valid_form.application_form = application_form
          expect{ valid_form.save }.to change { application_form.english_proficiencies.count }.by(1)
          english_proficiency = application_form.english_proficiencies.last
          expect(english_proficiency.draft).to be(true)
          expect(english_proficiency.has_qualification).to be(false)
          expect(english_proficiency.degree_taught_in_english).to be(false)
          expect(english_proficiency.qualification_not_needed).to be(false)
          expect(english_proficiency.no_qualification).to be(true)
          expect(
            english_proficiency.qualification_statuses,
            ).to contain_exactly('no_qualification')
        end
      end

      context 'when more than one qualification_status is given' do
        let(:application_form) { create(:application_form) }
        let(:qualification_statuses) { %w[has_qualification degree_taught_in_english qualification_not_needed ] }

        it 'creates a draft english proficiency' do
          valid_form.application_form = application_form
          expect{ valid_form.save }.to change { application_form.english_proficiencies.count }.by(1)
          english_proficiency = application_form.english_proficiencies.last
          expect(english_proficiency.draft).to be(true)
          expect(english_proficiency.has_qualification).to be(true)
          expect(english_proficiency.degree_taught_in_english).to be(true)
          expect(english_proficiency.qualification_not_needed).to be(true)
          expect(english_proficiency.no_qualification).to be(false)
          expect(
            english_proficiency.qualification_statuses,
            ).to contain_exactly('has_qualification', 'degree_taught_in_english', 'qualification_not_needed')
        end
      end
    end
  end

  describe '#next_path' do
    let(:form) do
      described_class.new(qualification_statuses:, application_form:)
    end
    let(:application_form) { create(:application_form) }
    let(:qualification_statuses) { ['has_qualification', 'qualification_not_needed'] }

    before { form.save }

    context 'when the english proficiency qualification includes "has_qualification"' do
      it 'returns the path for selecting a efl type' do
        english_proficiency = application_form.english_proficiencies.last
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/type/#{english_proficiency.id}",
        )
      end
    end

    context 'when the english proficiency qualification is "no_qualification"' do
      let(:qualification_statuses) { ['no_qualification'] }

      it 'returns the path for entering no qualification details' do
        english_proficiency = application_form.english_proficiencies.last
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/no-qualification-details/#{english_proficiency.id}",
        )
      end
    end

    context 'when the english proficiency qualification includes "degree_taught_in_english"' do
      let(:qualification_statuses) { ['degree_taught_in_english', 'qualification_not_needed'] }

      it 'returns the path for entering no qualification details' do
        english_proficiency = application_form.english_proficiencies.last
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/no-qualification-details/#{english_proficiency.id}",
        )
      end
    end

    context 'when the english proficiency qualification is "qualification_not_needed"' do
      let(:qualification_statuses) { ['qualification_not_needed'] }

      it 'returns the review path' do
        english_proficiency = application_form.english_proficiencies.last
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/review",
        )
      end
    end
  end

  describe '#fill' do
    let(:application_form) { create(:application_form) }

    context 'when the application has no english proficiencies' do
      it 'does not assign a qualification_statuses' do
        form = described_class.new.fill(application_form)
        expect(form.application_form).to eq(application_form)
        expect(form.qualification_statuses).to be_nil
      end
    end

    context 'when the application has an english proficiency' do
      before do
        create(
          :english_proficiency,
          application_form:,
          has_qualification: true,
          degree_taught_in_english: true,
          qualification_not_needed: true,
        )
      end

      it 'does not assign a qualification_statuses' do
        form = described_class.new.fill(application_form)
        expect(form.application_form).to eq(application_form)
        expect(form.qualification_statuses).to contain_exactly(
         'qualification_not_needed', 'degree_taught_in_english', 'has_qualification'
       )
      end
    end
  end
end
