require 'rails_helper'

RSpec.describe ApplicationForm do
  it 'sets a support reference upon creation' do
    application_form = create :application_form
    expect(application_form.support_reference).to be_present
  end

  describe 'auditing', with_audited: true do
    it 'records an audit entry when creating a new ApplicationForm' do
      application_form = create :application_form
      expect(application_form.audits.count).to eq 1
    end

    it 'can view audit records for ApplicationForm and its associated ApplicationChoices' do
      application_form = create(:completed_application_form, application_choices_count: 1)

      expect {
        application_form.application_choices.first.update!(rejection_reason: 'rejected')
      }.to change { application_form.own_and_associated_audits.count }.by(1)
    end
  end

  describe '#science_gcse_needed?' do
    context 'when a candidate has no course choices' do
      it 'returns false' do
        application_form = build_stubbed(:application_form)

        expect(application_form.science_gcse_needed?).to eq(false)
      end
    end

    context 'when a candidate has a course choice that is primary' do
      it 'returns true' do
        application_form = application_form_with_course_option_for_provider_with(level: 'primary')

        expect(application_form.science_gcse_needed?).to eq(true)
      end
    end

    context 'when a candidate has a course choice that is secondary' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'secondary')

        expect(application_form.science_gcse_needed?).to eq(false)
      end
    end

    context 'when a candidate has a course choice that is further education' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'further_education')

        expect(application_form.science_gcse_needed?).to eq(false)
      end
    end

    def application_form_with_course_option_for_provider_with(level:)
      provider = build(:provider)
      course = create(:course, level: level, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_form = create(:application_form)

      create(
        :application_choice,
        application_form: application_form,
        course_option: course_option,
      )

      application_form
    end
  end

  describe '#blank_application?' do
    context 'when a candidate has not made any alterations to their applicaiton' do
      it 'returns true' do
        application_form = create(:application_form)
        expect(application_form.blank_application?).to be_truthy
      end
    end

    context 'when a candidate has amended their application' do
      it 'returns false' do
        application_form = create(:application_form)
        create(:application_work_experience, application_form: application_form)
        expect(application_form.blank_application?).to be_falsey
      end
    end
  end

  describe '#references_where_feedback_requested_or_feedback_provided' do
    it 'only returns references with a status of feedback requested or feedback provided' do
      application_form = create(:application_form)
      reference1 = create(:reference, application_form: application_form, feedback_status: 'feedback_provided')
      reference2 = create(:reference, application_form: application_form, feedback_status: 'feedback_requested')
      create(:reference, application_form: application_form, feedback_status: 'cancelled')

      expect(application_form.references_where_feedback_requested_or_feedback_provided).to eq([reference1, reference2])
    end
  end
end
