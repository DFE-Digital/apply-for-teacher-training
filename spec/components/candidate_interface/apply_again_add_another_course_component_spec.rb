require 'rails_helper'

RSpec.describe CandidateInterface::ApplyAgainAddAnotherCourseComponent do
  subject(:result) { render_inline(described_class.new(application_form: application_form)) }

  let(:application_form) { create(:application_form, phase: 'apply_2') }

  context 'when the number of courses chosen is 1' do
    before do
      create(:application_choice, application_form: application_form)
    end

    it 'renders you can add 2 more courses' do
      expect(result.text).to include('You can add 2 more courses')
    end
  end

  context 'when the number of courses chosen is 2' do
    before do
      create(:application_choice, application_form: application_form)
      create(:application_choice, application_form: application_form)
    end

    it 'renders you can add 1 more course' do
      expect(result.text).to include('You can add 1 more course')
    end
  end
end
