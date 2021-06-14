require 'rails_helper'

RSpec.describe GenerateFakeProvider do
  let(:provider_hash) { { name: 'Fake Provider', code: 'FAKE' } }

  subject(:generate_provider_call) { described_class.generate_provider(provider_hash) }

  describe '.generate_provider' do
    it 'raises an error in production' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        expect { generate_provider_call }.to raise_error(RuntimeError, 'You cannot generate test data in production')
      end
    end

    it 'generates a new provider and a test training provider for ratified courses' do
      expect { generate_provider_call }
        .to change { Provider.count }.by(2)
    end

    it 'turns on syncing for the provider' do
      new_provider = generate_provider_call

      expect(new_provider.sync_courses).to be true
    end

    describe 'courses and course options' do
      let(:fake_provider) { Provider.find_by(code: 'FAKE') }

      before { generate_provider_call }

      it 'generates 10 courses run by the fake provider, with associated options' do
        courses = fake_provider.courses

        expect(courses.count).to eq(10)
        expect(courses).to all(be_open_on_apply)
        expect(courses.map(&:course_options)).to all(be_present)
      end

      it 'generates 3 courses ratified by the fake provider, with associated options' do
        accredited_courses = fake_provider.accredited_courses
        permission = fake_provider.ratifying_provider_permissions.first

        expect(accredited_courses.count).to eq(3)
        expect(accredited_courses).to all(be_open_on_apply)
        expect(accredited_courses.map(&:course_options)).to all(be_present)
        expect(permission.ratifying_provider_can_make_decisions).to be(true)
      end
    end
  end
end
