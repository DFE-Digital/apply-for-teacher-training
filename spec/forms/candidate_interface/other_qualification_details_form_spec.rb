require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationDetailsForm do
  let(:error_message_scope) do
    'activemodel.errors.models.candidate_interface/other_qualification_details_form.attributes.'
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:award_year).on(:details) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
    it { is_expected.to validate_length_of(:grade).is_at_most(255) }
    it { is_expected.to validate_length_of(:other_uk_qualification_type).is_at_most(100) }

    describe 'subject' do
      it 'validates presence except for non-uk and other qualifications' do
        non_uk_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'non_uk', subject: nil)
        other_uk_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'Other', subject: nil)
        gcse = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'GCSE', subject: nil)

        non_uk_qualification.valid?(:details)
        other_uk_qualification.valid?(:details)
        gcse.valid?(:details)

        expect(non_uk_qualification.errors.full_messages_for(:subject)).to be_empty
        expect(other_uk_qualification.errors.full_messages_for(:subject)).to be_empty
        expect(gcse.errors.full_messages_for(:subject)).not_to be_empty
      end
    end

    describe 'grade' do
      it 'validates presence except for non-uk and other qualifications' do
        non_uk_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'non_uk', grade: nil)
        other_uk_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'Other', grade: nil)
        gcse = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'GCSE', grade: nil)

        non_uk_qualification.valid?(:details)
        other_uk_qualification.valid?(:details)
        gcse.valid?(:details)

        expect(non_uk_qualification.errors.full_messages_for(:grade)).to be_empty
        expect(other_uk_qualification.errors.full_messages_for(:grade)).to be_empty
        expect(gcse.errors.full_messages_for(:grade)).not_to be_empty
      end

      it 'validates grade format for A/AS levels, sanitizing the string in the process' do
        valid_a_level = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'A level', grade: 'a* a*')
        valid_as_level = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'AS level', grade: 'b  b')
        valid_other_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'Other', grade: 'Gold star')
        invalid_a_level = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'A level', grade: 'a* a* b')
        invalid_as_level = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'AS level', grade: '85%')

        [valid_a_level, valid_as_level, invalid_a_level, invalid_as_level, valid_other_qualification].each { |q| q.valid?(:details) }

        expect(valid_a_level.errors.messages[:grade]).to be_blank
        expect(valid_a_level.grade).to eq 'A*A*'
        expect(valid_as_level.errors.messages[:grade]).to be_blank
        expect(valid_as_level.grade).to eq 'BB'
        expect(valid_other_qualification.errors.messages[:grade]).to be_blank
        expect(valid_other_qualification.grade).to eq 'Gold star'

        expect(invalid_a_level.errors.messages[:grade].pop).to eq 'Enter a real grade'
        expect(invalid_as_level.errors.messages[:grade].pop).to eq 'Enter a real grade'
      end
    end

    it 'validates grade format for GCSE, sanitizing the string in the process' do
      valid_gcse_one = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'GCSE', grade: '9 - 8')
      valid_gcse_two = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'GCSE', grade: 'e   e')
      valid_other_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'Other', grade: 'Gold star')
      invalid_gcse = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'GCSE', grade: '5%')

      [valid_gcse_one, valid_gcse_two, valid_other_qualification, invalid_gcse].each { |q| q.valid?(:details) }

      expect(valid_gcse_one.errors.messages[:grade]).to be_blank
      expect(valid_gcse_one.grade).to eq '9-8'
      expect(valid_gcse_two.errors.messages[:grade]).to be_blank
      expect(valid_gcse_two.grade).to eq 'EE'
      expect(valid_other_qualification.errors.messages[:grade]).to be_blank
      expect(valid_other_qualification.grade).to eq 'Gold star'

      expect(invalid_gcse.errors.messages[:grade].pop).to eq 'Enter a real grade'
    end

    it { is_expected.to validate_presence_of(:subject).on(:details) }
    it { is_expected.to validate_presence_of(:grade).on(:details) }

    describe 'institution country' do
      context 'when it is a non-uk qualification' do
        it 'validates for presence and inclusion in the COUNTY_NAMES constant' do
          valid_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'non_uk', institution_country: 'GB')
          blank_country_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'non_uk')
          inavlid_country_qualification = CandidateInterface::OtherQualificationDetailsForm.new(nil, nil, qualification_type: 'non_uk', institution_country: 'QQ')

          valid_qualification.valid?(:details)
          blank_country_qualification.valid?(:details)
          inavlid_country_qualification.valid?(:details)

          expect(valid_qualification.errors.full_messages_for(:institution_country)).to be_empty
          expect(blank_country_qualification.errors.full_messages_for(:institution_country)).not_to be_empty
          expect(inavlid_country_qualification.errors.full_messages_for(:institution_country)).not_to be_empty
        end
      end
    end

    describe 'award year' do
      context 'year validations' do
        let(:model) do
          described_class.new(nil, nil, award_year: award_year)
        end

        include_examples 'year validations',
                         :award_year,
                         future: true
      end
    end
  end

  describe '.build_all_from_application' do
    let(:application_form) do
      create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'other',
          created_at: Time.zone.local(2019, 1, 1, 1, 9, 0, 0),
        )
        form.application_qualifications.create(
          level: 'other',
          qualification_type: 'BTEC',
          subject: 'Being a Superhero',
          grade: 'Distinction',
          predicted_grade: false,
          award_year: '2012',
          created_at: Time.zone.local(2019, 1, 1, 21, 0, 0),
        )
        form.application_qualifications.create(level: 'degree')
        form.application_qualifications.create(level: 'gcse')
      end
    end

    it 'creates an array of objects based on the provided ApplicationForm' do
      qualifications = CandidateInterface::OtherQualificationDetailsForm.build_all(application_form)

      expect(qualifications).to include(
        have_attributes(
          qualification_type: 'BTEC',
          subject: 'Being a Superhero',
          grade: 'Distinction',
          award_year: '2012',
        ),
      )
    end

    it 'only includes other qualifications and not degrees or GCSEs' do
      qualifications = CandidateInterface::OtherQualificationDetailsForm.build_all(application_form)

      expect(qualifications.count).to eq(2)
    end

    it 'orders other qualifications by created at' do
      qualifications = CandidateInterface::OtherQualificationDetailsForm.build_all(application_form)

      expect(qualifications.last).to have_attributes(
        qualification_type: 'BTEC',
        subject: 'Being a Superhero',
      )
    end
  end

  describe '.build_from_qualification' do
    it 'returns a new OtherQualificationDetailsForm object using an application qualification' do
      application_qualification = build_stubbed(
        :application_qualification,
        level: 'other',
        qualification_type: 'BTEC',
        subject: 'Being a Sidekick',
        grade: 'Merit',
        predicted_grade: false,
        award_year: '2010',
      )

      qualification = CandidateInterface::OtherQualificationDetailsForm.build_from_qualification(application_qualification)

      expect(qualification).to have_attributes(qualification_type: 'BTEC', subject: 'Being a Sidekick')
    end
  end

  describe '#initialize_from_last_qualification' do
    it 'sets choice' do
      qualification = build_stubbed(
        :application_qualification,
      )

      last_qualification = CandidateInterface::OtherQualificationDetailsForm.new(
        nil,
        nil,
      )

      last_qualification.initialize_from_last_qualification([qualification])

      expect(last_qualification.choice).to eq('no')
    end

    context 'blank qualifications' do
      it 'returns nil' do
        last_qualification = CandidateInterface::OtherQualificationDetailsForm.new
        expect(last_qualification.initialize_from_last_qualification([])).to be_nil
      end
    end

    context 'previous qualification is same type' do
      it 'sets institution_country and award_year' do
        qualification_type = 'foo'

        qualification = build_stubbed(
          :application_qualification,
          qualification_type: qualification_type,
        )

        last_qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: qualification_type,
        )

        last_qualification.initialize_from_last_qualification([qualification])

        expect(last_qualification.institution_country).to eq(qualification.institution_country)
        expect(last_qualification.award_year).to eq(qualification.award_year)
      end
    end

    context 'qualification is non-uk' do
      it 'sets non_uk_qualification_type' do
        non_uk = 'non_uk'

        qualification = build_stubbed(
          :application_qualification,
          qualification_type: non_uk,
        )

        last_qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'foo',
        )

        last_qualification.initialize_from_last_qualification([qualification])

        expect(last_qualification.non_uk_qualification_type).to eq(qualification.non_uk_qualification_type)
      end
    end

    context 'qualification is other' do
      it 'sets other_uk_qualification_type' do
        other = 'Other'

        qualification = build_stubbed(
          :application_qualification,
          qualification_type: 'foo',
        )

        last_qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: other,
        )

        last_qualification.initialize_from_last_qualification([qualification])

        expect(last_qualification.other_uk_qualification_type).to eq(qualification.other_uk_qualification_type)
      end
    end
  end

  describe '#title' do
    context 'for a non-uk qualification' do
      it 'concatenates the non_uk_qualification_type and subject' do
        qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'Master Craftsman',
          subject: 'Igloo Building 101',
        )

        expect(qualification.title).to eq('Master Craftsman Igloo Building 101')
      end
    end

    context 'for an other uk qualification' do
      it 'concatenates the other_uk_qualification_type and subject' do
        qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'Other',
          other_uk_qualification_type: 'Master Craftsman',
          subject: 'Chopping Trees 1-0-done',
        )

        expect(qualification.title).to eq('Master Craftsman Chopping Trees 1-0-done')
      end
    end

    context 'for other uk qualificaitons and GCSEs and A-levels' do
      it 'concatenates the qualification type and subject' do
        qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'BTEC',
          subject: 'Being a Supervillain',
        )

        expect(qualification.title).to eq('BTEC Being a Supervillain')
      end
    end
  end

  describe '#qualification_type_name' do
    context 'for a non-uk qualification' do
      it 'returns the non_uk_qualification_type' do
        qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'Master Craftsman',
        )

        expect(qualification.qualification_type_name).to eq('Master Craftsman')
      end
    end

    context 'for an other uk qualification with the qualification type Other' do
      it 'returns the other_uk_qualification_type' do
        qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'Other',
          other_uk_qualification_type: 'Master Craftsman',
        )

        expect(qualification.qualification_type_name).to eq('Master Craftsman')
      end
    end

    context 'for other uk qualifications and GCSEs and A-levels' do
      it 'returns the qualification type' do
        qualification = CandidateInterface::OtherQualificationDetailsForm.new(
          nil,
          nil,
          qualification_type: 'BTEC',
        )

        expect(qualification.qualification_type_name).to eq('BTEC')
      end
    end
  end

  describe '#grade_hint' do
    it 'returns a GCSE hint if qualification_type is GCSE_TYPE' do
      qualification = described_class.new(
        nil,
        nil,
        current_step: :details,
        qualification_type: 'GCSE',
      )

      expect(qualification.grade_hint).to eq({ text: 'For example, ‘C’, ‘CD’, ‘4’ or ‘4-3’' })
    end

    it 'returns nil for any other qualification_type' do
      namespace = CandidateInterface::OtherQualificationTypeForm

      (namespace::ALL_VALID_TYPES - [namespace::GCSE_TYPE]).each do |qualification_type|
        qualification = described_class.new(
          nil,
          nil,
          current_step: :details,
          qualification_type: qualification_type,
        )

        expect(qualification.grade_hint).to eq nil
      end
    end
  end
end
