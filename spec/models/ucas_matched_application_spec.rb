require 'rails_helper'

RSpec.describe UCASMatchedApplication do
  let(:course) { create(:course) }
  let(:candidate) { create(:candidate) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_choice) { create(:application_choice, course_option: course_option) }
  let(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }

  before do
    application_form
  end

  describe '#course' do
    it 'returns the course' do
      ucas_matching_data =
        { 'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

      expect(ucas_matching_application.course).to eq(course)
    end
  end

  describe '#status' do
    context 'when it is a DfE match' do
      it 'returns the applications status' do
        dfe_matching_data =
          { 'Scheme' => 'D',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(dfe_matching_data)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end

    context 'when it is a UCAS match' do
      it 'returns the applications status' do
        ucas_matching_data =
          { 'Scheme' => 'U',
            'Offers' => '.',
            'Rejects' => '1',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.status).to eq('rejected')
        expect(ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map(&:to_s)).to include(ucas_matching_application.status)
      end
    end

    context 'when it is a match on both systems' do
      it 'returns the applications status on apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s,
            'Offers' => '.',
            'Rejects' => '1',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end
  end
end
