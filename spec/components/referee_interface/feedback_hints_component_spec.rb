require 'rails_helper'

RSpec.describe RefereeInterface::FeedbackHintsComponent do
  let!(:application_form) { create(:application_form, first_name: 'Hal', last_name: 'Brand') }
  let(:course_option) { create(:course_option, course: create(:course, provider: create(:provider, name: 'University of Warwick'))) }
  let!(:application_choice) { create(:application_choice, :accepted, application_form:, course_option:) }
  let(:reference) { create(:reference, referee_type: nil, application_form:) }

  describe '#reference_hints' do
    it 'displays the correct hints for academic references' do
      reference.referee_type = :academic
      render_inline(described_class.new(reference:))

      expect(rendered_content).to have_text('when their course started and ended')
      expect(rendered_content).to have_text('their academic record')
      expect(rendered_content).to have_css('li', count: 2)
    end

    %i[professional school_based].each do |referee_type|
      it "displays the correct hints for #{referee_type} references" do
        reference.referee_type = referee_type

        render_inline(described_class.new(reference:))

        expect(rendered_content).to have_text('when they worked with you')
        expect(rendered_content).to have_text('their role and responsibilities')
        expect(rendered_content).to have_css('li', count: 2)
      end
    end

    it 'displays the correct hints for character references' do
      reference.referee_type = :character

      render_inline(described_class.new(reference:))

      expect(rendered_content).to have_text('details of how you know Hal Brand')
      expect(rendered_content).to have_text('things they’ve done or you have done together')
      expect(rendered_content).to have_css('li', count: 2)
    end
  end

  describe '#provider_name' do
    it 'returns provider name for application that is pending_conditions' do
      expect(described_class.new(reference:).provider_name).to eql('University of Warwick')
    end

    context 'when application is recruited' do
      let(:course_option) { create(:course_option, course: create(:course, provider: create(:provider, name: 'University of Cambridge'))) }
      let(:application_choice) { create(:application_choice, :recruited, application_form:, course_option:) }

      it 'returns provider name' do
        expect(described_class.new(reference:).provider_name).to eql('University of Cambridge')
      end
    end
  end

  describe '#candidate_full_name' do
    it 'returns full name of candidate' do
      expect(described_class.new(reference:).candidate_full_name).to eql('Hal Brand')
    end
  end
end
