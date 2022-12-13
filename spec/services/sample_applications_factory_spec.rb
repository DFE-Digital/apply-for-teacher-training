require 'rails_helper'

RSpec.describe SampleApplicationsFactory do
  describe '.generate_applications(count, provider:)' do
    subject(:applications) { described_class.generate_applications(count, provider:) }

    let(:count) { 3 }
    let(:provider) { create(:provider) }

    before do
      2.times do
        course = create(:course, :open_on_apply, provider:)
        create(:course_option, course:)
      end
    end

    it 'returns n `ApplicationForm`s' do
      expect(applications.count).to eq(count)
      expect(applications).to all(be_an(ApplicationForm))
    end

    it 'creates an `awaiting_provider_decision` application choice for each form, with a course from the training provider' do
      applications.each do |application|
        expect(application.application_choices.count).to eq(1)
        expect(application.application_choices.first.course.provider).to eq(provider)
        expect(application.application_choices.first).to be_awaiting_provider_decision
      end
    end
  end
end
