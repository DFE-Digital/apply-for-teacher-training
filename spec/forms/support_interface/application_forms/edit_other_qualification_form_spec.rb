require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditOtherQualificationForm, :with_audited, type: :model do
  let(:form) { described_class.new(qualification) }
  let(:qualification) { create(:as_level_qualification) }
  let(:zendesk_ticket) { 'www.becomingateacher.zendesk.com/agent/tickets/example' }

  describe '#save' do
    let(:award_year) { Time.zone.now.year }
    let(:grade) { 'B' }
    let(:subject) { 'Maths' }

    it 'updates the qualification if valid' do
      form.assign_attributes(subject:, award_year:, audit_comment: zendesk_ticket, grade:)

      form.save!

      expect(form).to be_valid
      expect(qualification.reload.subject).to eq subject
      expect(qualification.reload.grade).to eq grade
      expect(qualification.reload.award_year).to eq award_year.to_s
      expect(qualification.audits.last.comment).to include(zendesk_ticket)
    end
  end

  describe '#assign_attributes_for_qualification' do
    let(:params) do
      {
        qualification_type: described_class::OTHER_TYPE,
        subject: 'Other qual',
        grade: 'A',
        award_year: '2020',
        other_uk_qualification_type: 'Extended Project',
        audit_comment: zendesk_ticket,
      }
    end

    it 'correctly assigns general attributes' do
      form.assign_attributes_for_qualification(params)
      expect(form.subject).to eq 'Other qual'
      expect(form.grade).to eq 'A'
      expect(form.award_year).to eq '2020'
    end

    it 'assigns other_uk_qualification_type when qualification_type is OTHER_TYPE' do
      form.assign_attributes_for_qualification(params)
      expect(form.other_uk_qualification_type).to eq 'Extended Project'
    end

    it 'does not assign non_uk_qualification_type when qualification_type is OTHER_TYPE' do
      form.assign_attributes_for_qualification(params)
      expect(form.non_uk_qualification_type).to be_nil
    end

    context 'when qualification type is NON_UK_TYPE' do
      before do
        params.merge!(
          qualification_type: described_class::NON_UK_TYPE,
          non_uk_qualification_type: 'International Baccalaureate',
        )
      end

      it 'assigns non_uk_qualification_type correctly' do
        form.assign_attributes_for_qualification(params)
        expect(form.non_uk_qualification_type).to eq 'International Baccalaureate'
      end

      it 'does not assign other_uk_qualification_type' do
        form.assign_attributes_for_qualification(params)
        expect(form.other_uk_qualification_type).to be_nil
      end
    end
  end

  describe '#sanitize_grade_where_required' do
    it 'sanitizes grade for AS level qualifications' do
      form.assign_attributes(qualification_type: described_class::AS_LEVEL_TYPE, grade: ' a ', audit_comment: zendesk_ticket)
      form.valid?
      expect(form.grade).to eq 'A'
    end

    it 'sanitizes grade for A level qualifications' do
      form.assign_attributes(qualification_type: described_class::A_LEVEL_TYPE, grade: ' a ', audit_comment: zendesk_ticket)
      form.valid?
      expect(form.grade).to eq 'A'
    end

    it 'sanitizes grade for GCSE qualifications' do
      form.assign_attributes(qualification_type: described_class::GCSE_TYPE, grade: ' a ', audit_comment: zendesk_ticket)
      form.valid?
      expect(form.grade).to eq 'A'
    end

    it 'does not sanitize grade for other qualifications' do
      form.assign_attributes(qualification_type: described_class::OTHER_TYPE, grade: ' a ', audit_comment: zendesk_ticket)
      form.valid?
      expect(form.grade).to eq ' a '
    end
  end

  describe 'validations' do
    let(:invalid_award_year) { Time.zone.now.year + 4 }
    let(:long_string) { 'a' * 256 }
    let(:invalid_url) { 'invalid_url' }

    it 'is invalid with a future award year' do
      form.assign_attributes(award_year: invalid_award_year, audit_comment: zendesk_ticket)

      expect(form).not_to be_valid
    end

    it 'is invalid without a subject' do
      form.assign_attributes(subject: nil, audit_comment: zendesk_ticket)
      expect(form).not_to be_valid
    end

    it 'is invalid without a grade' do
      form.assign_attributes(grade: nil, audit_comment: zendesk_ticket)
      expect(form).not_to be_valid
    end

    it 'is invalid without an award_year' do
      form.assign_attributes(award_year: nil, audit_comment: zendesk_ticket)
      expect(form).not_to be_valid
    end

    it 'is valid with a subject, grade, award_year and audit_comment' do
      form.assign_attributes(audit_comment: zendesk_ticket)
      expect(form).to be_valid
    end

    it 'is invalid with a subject longer than 255 characters' do
      form.assign_attributes(subject: long_string, audit_comment: zendesk_ticket)
      expect(form).not_to be_valid
    end

    it 'does not require a grade for non-UK qualifications' do
      form.assign_attributes(qualification_type: described_class::NON_UK_TYPE, non_uk_qualification_type: 'non uk qual', grade: nil, audit_comment: zendesk_ticket)
      expect(form).to be_valid
    end

    it 'is invalid with a grade longer than 255 characters' do
      form.assign_attributes(grade: long_string, audit_comment: zendesk_ticket)
      expect(form).not_to be_valid
    end

    it 'is invalid with a other_uk_qualification_type longer than 100 characters' do
      form.assign_attributes(qualification_type: described_class::OTHER_TYPE, other_uk_qualification_type: long_string, audit_comment: zendesk_ticket)
      expect(form).not_to be_valid
    end

    it 'is invalid with an incorrect audit_comment format' do
      form.assign_attributes(audit_comment: invalid_url)
      expect(form).not_to be_valid
    end

    context 'when qualification type is Other' do
      it 'is invalid without other_uk_qualification_type' do
        form.assign_attributes(qualification_type: described_class::OTHER_TYPE,
                               other_uk_qualification_type: nil,
                               audit_comment: zendesk_ticket)
        expect(form).not_to be_valid
        expect(form.errors[:other_uk_qualification_type]).to include('Enter the type of qualification')
      end
    end

    context 'when qualification type is not Other' do
      it 'is valid without other_uk_qualification_type' do
        form.assign_attributes(qualification_type: described_class::A_LEVEL_TYPE,
                               other_uk_qualification_type: nil,
                               audit_comment: zendesk_ticket)
        expect(form).to be_valid
      end
    end

    context 'when qualification type is non-UK' do
      it 'is invalid without non_uk_qualification_type' do
        form.assign_attributes(qualification_type: described_class::NON_UK_TYPE,
                               non_uk_qualification_type: nil,
                               audit_comment: zendesk_ticket)
        expect(form).not_to be_valid
        expect(form.errors[:non_uk_qualification_type]).to include('Enter the type of qualification')
      end
    end

    context 'when qualification type is not non-UK' do
      it 'is valid without non_uk_qualification_type' do
        form.assign_attributes(qualification_type: described_class::A_LEVEL_TYPE,
                               non_uk_qualification_type: nil,
                               audit_comment: zendesk_ticket)
        expect(form).to be_valid
      end
    end

    it 'validates with SafeChoiceUpdateValidator' do
      expect(form.class.validators.map(&:class)).to include(SafeChoiceUpdateValidator)
    end
  end
end
