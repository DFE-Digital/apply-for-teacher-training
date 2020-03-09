require 'rails_helper'

RSpec.describe CandidateInterface::SafeguardingIssuesDeclarationForm, type: :model do
  describe '.build_from_application' do
    context 'when safeguarding issues does not have a value' do
      it 'creates an object based on the application form' do
        application_form = build_stubbed(:application_form, safeguarding_issues: nil)

        form = CandidateInterface::SafeguardingIssuesDeclarationForm.build_from_application(application_form)

        expect(form.share_safeguarding_issues).to eq(nil)
        expect(form.safeguarding_issues).to eq(nil)
      end
    end

    context 'when safeguarding issues has a value of "Yes"' do
      it 'creates an object based on the application form' do
        application_form = build_stubbed(:application_form, safeguarding_issues: 'Yes')

        form = CandidateInterface::SafeguardingIssuesDeclarationForm.build_from_application(application_form)

        expect(form.share_safeguarding_issues).to eq('Yes')
        expect(form.safeguarding_issues).to eq(nil)
      end
    end

    context 'when safeguarding issues has a value of "No"' do
      it 'creates an object based on the application form' do
        application_form = build_stubbed(:application_form, safeguarding_issues: 'No')

        form = CandidateInterface::SafeguardingIssuesDeclarationForm.build_from_application(application_form)

        expect(form.share_safeguarding_issues).to eq('No')
        expect(form.safeguarding_issues).to eq(nil)
      end
    end

    context 'when safeguarding issues has details' do
      it 'creates an object based on the application form' do
        application_form = build_stubbed(:application_form, safeguarding_issues: 'I have a criminal conviction.')

        form = CandidateInterface::SafeguardingIssuesDeclarationForm.build_from_application(application_form)

        expect(form.share_safeguarding_issues).to eq('Yes')
        expect(form.safeguarding_issues).to eq('I have a criminal conviction.')
      end
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form) }

    context 'when sharing safeguarding issues is blank' do
      it 'returns false' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when sharing safeguarding issues is "No"' do
      it 'returns true' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(share_safeguarding_issues: 'No')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates safeguarding issues of the application form to "No"' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(share_safeguarding_issues: 'No')

        form.save(application_form)

        expect(application_form.safeguarding_issues).to eq('No')
      end
    end

    context 'when sharing safeguarding issues is "Yes" but no details provided' do
      it 'returns true' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(
          share_safeguarding_issues: 'Yes',
          safeguarding_issues: '',
        )

        expect(form.save(application_form)).to be(true)
      end

      it 'updates safeguarding issues of the application form to provided issues if empty string' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(
          share_safeguarding_issues: 'Yes',
          safeguarding_issues: '',
        )

        form.save(application_form)

        expect(application_form.safeguarding_issues).to eq('Yes')
      end

      it 'updates safeguarding issues of the application form to provided issues if nil' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(
          share_safeguarding_issues: 'Yes',
          safeguarding_issues: nil,
        )

        form.save(application_form)

        expect(application_form.safeguarding_issues).to eq('Yes')
      end
    end

    context 'when sharing safeguarding issues is "Yes" and details provided' do
      it 'returns true' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(
          share_safeguarding_issues: 'Yes',
          safeguarding_issues: 'I have a criminal conviction.',
        )

        expect(form.save(application_form)).to be(true)
      end

      it 'updates safeguarding issues of the application form to provided issues' do
        form = CandidateInterface::SafeguardingIssuesDeclarationForm.new(
          share_safeguarding_issues: 'Yes',
          safeguarding_issues: 'I have a criminal conviction.',
        )

        form.save(application_form)

        expect(application_form.safeguarding_issues).to eq('I have a criminal conviction.')
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:share_safeguarding_issues) }

    valid_text = Faker::Lorem.sentence(word_count: 400)
    invalid_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(valid_text).for(:safeguarding_issues) }
    it { is_expected.not_to allow_value(invalid_text).for(:safeguarding_issues) }
  end
end
