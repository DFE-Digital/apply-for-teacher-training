require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverBannerComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when latest application is unsuccessful and in the current recruitment cycle' do
    it 'renders nothing' do
      Timecop.freeze(Time.zone.local(2020, 8, 1, 12, 0, 0)) do
        create(:application_choice, application_form: application_form, status: 'cancelled')
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.text).to be_blank
      end
    end
  end

  context 'when latest application is unsuccessful and in the previous recruitment cycle' do
    it 'renders component with correct values' do
      Timecop.freeze(Time.zone.local(2020, 8, 1, 12, 0, 0)) do
        create(:application_choice, application_form: application_form, status: 'cancelled')
        Timecop.freeze(Time.zone.local(2020, 10, 24, 12, 0, 0)) do
          result = render_inline(described_class.new(application_form: application_form))

          expect(result.text).to eq 'foo'
        end
      end
    end
  end

  describe 'deadline copy' do
  end

  describe 'visibility of banner between cycles' do
    # it 'is rendered during cycle' do
    #   Timecop.freeze(Time.zone.local(2020, 9, 17, 12, 0, 0)) do
    #     result = render_inline(described_class.new(application_form: application_form))
    #     expect(result.text).to include('Do you want to apply again?')
    #   end
    # end

    # it 'is not rendered between cycles' do
    #   Timecop.freeze(Time.zone.local(2020, 9, 25, 12, 0, 0)) do
    #     result = render_inline(described_class.new(application_form: application_form))
    #     expect(result.text).to eq('')
    #   end
    # end
  end
end
