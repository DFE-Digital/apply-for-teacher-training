require 'rails_helper'

RSpec.describe EnqueueTriggeredDuplicateMatchCheck do
  let(:application_form) do
    create(
      :application_form,
      last_name: 'Smith',
      date_of_birth: Date.new(1990, 1, 1),
      address_line1: nil,
      address_line2: nil,
      address_line3: nil,
      address_line4: nil,
      postcode: nil,
      personal_details_completed: false,
      contact_details_completed: false,
    )
  end

  before { application_form }

  describe '#call' do
    described_class::ADDRESS_FIELDS.each do |field|
      it "enqueues when #{field} changes with personal details present" do
        value = { 'postcode' => 'SW1A 1AA', 'address_type' => 'international', 'country' => 'FR' }.fetch(field, 'Example address')

        expect do
          described_class.new(application_form).call { application_form.update!(field => value) }
        end.to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker).with(application_form.id).exactly(:once)
      end
    end

    %w[last_name date_of_birth].each do |field|
      %w[postcode address_line1 address_line2 address_line3 address_line4].each do |address_field|
        it "enqueues when #{field} changes and only #{address_field} is entered" do
          application_form.update!(address_field => (address_field == 'postcode' ? 'SW1A 1AA' : 'Example address'))
          value = field == 'last_name' ? 'Jones' : Date.new(1991, 1, 1)

          expect do
            described_class.new(application_form).call { application_form.update!(field => value) }
          end.to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker).with(application_form.id).exactly(:once)
        end
      end
      it "does not enqueue an address change when #{field} is missing" do
        application_form.update!(field => nil)

        expect do
          described_class.new(application_form).call { application_form.update!(address_line1: 'Example address') }
        end.not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
      end
    end

    it 'does not enqueue personal changes without an address' do
      expect do
        described_class.new(application_form).call { application_form.update!(last_name: 'Jones') }
      end.not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
    end

    it 'does not count whitespace-only address lines as an address' do
      application_form.update!(address_line2: '   ')

      expect do
        described_class.new(application_form).call { application_form.update!(last_name: 'Jones') }
      end.not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
    end

    it 'does not enqueue when values are unchanged' do
      expect do
        described_class.new(application_form).call { application_form.update!(last_name: 'Smith') }
      end.not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
    end

    it 'does not enqueue when unrelated fields or completion flags change' do
      expect do
        described_class.new(application_form).call do
          application_form.update!(first_name: 'Alex', personal_details_completed: true, contact_details_completed: true)
        end
      end.not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
    end

    it 'does not enqueue when a save returns false' do
      expect do
        result = described_class.new(application_form).call do
          application_form.address_line1 = 'Example address'
          false
        end
        expect(result).to be(false)
      end.not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
    end

    it 'preserves successful return values and enqueues once for multiple changes' do
      expect do
        result = described_class.new(application_form).call do
          application_form.update!(last_name: 'Jones', address_line1: 'Example address')
        end
        expect(result).to be(true)
      end.to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker).with(application_form.id).exactly(:once)
    end

    it 'does not lose changes when another save occurs in the block' do
      expect do
        described_class.new(application_form).call do
          application_form.update!(address_line1: 'Example address')
          application_form.update!(first_name: 'Alex')
        end
      end.to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker).with(application_form.id).exactly(:once)
    end

    it 'does not enqueue for a direct model update' do
      expect { application_form.update!(address_line1: 'Example address') }
        .not_to have_enqueued_job(UpdateTriggeredDuplicateMatchesWorker)
    end
  end
end
