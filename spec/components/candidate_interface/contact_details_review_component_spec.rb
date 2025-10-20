require 'rails_helper'

RSpec.describe CandidateInterface::ContactDetailsReviewComponent, type: :component do
  let(:application_form) do
    build_stubbed(
      :application_form,
      phone_number: '07700 900 982',
      address_line1: '42',
      address_line2: 'Much Wow Street',
      address_line3: 'London',
      address_line4: 'England',
      postcode: 'SW1P 3BT',
    )
  end

  context 'when contact details are editable' do
    it 'renders component with correct values for a phone number' do
      render_inline(described_class.new(application_form:)) do |rendered_component|
        expect(rendered_component).to summarise(
          key: 'Phone number',
          value: '07700 900 982',
          action: {
            text: 'Change phone number',
            href: Rails.application.routes.url_helpers.candidate_interface_edit_phone_number_path,
          },
        )
      end
    end

    context 'when contact details are completed' do
      it 'renders component with correct values for a UK address' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.contact_details.full_address.label'))
        expect(result.css('.govuk-summary-list__value').to_html).to include('42<br role="presentation">Much Wow Street<br role="presentation">London<br role="presentation">England<br role="presentation">SW1P 3BT')
        expect(result.css('.govuk-summary-list__actions a')[1].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_edit_address_type_path)
        expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.contact_details.full_address.change_action')}")
      end

      it 'renders component with correct values for an international address' do
        application_form = build_stubbed(
          :application_form,
          phone_number: '+91 1234567890',
          address_type: 'international',
          address_line1: '321 MG Road',
          address_line3: 'Mumbai',
          country: 'IN',
        )
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.contact_details.full_address.label'))
        expect(result.css('.govuk-summary-list__value').to_html).to include('321 MG Road<br role="presentation">Mumbai<br role="presentation">India')
        expect(result.css('.govuk-summary-list__actions a')[1].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_edit_address_type_path)
        expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.contact_details.full_address.change_action')}")
      end
    end

    context 'when contact details are incomplete' do
      it 'renders an Enter phone number and Enter address link' do
        application_form = build_stubbed(
          :application_form,
          phone_number: nil,
          address_type: 'international',
          address_line1: '',
          country: 'IN',
        )
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__value .govuk-link').to_html).to include('Enter phone number')
        expect(result.css('.govuk-summary-list__value .govuk-link').to_html).to include('Enter address')
      end

      it 'renders an Enter postcode link if only the postcode is missing' do
        application_form = build_stubbed(
          :application_form,
          phone_number: '0123456789',
          address_type: 'uk',
          address_line1: '1 Nothrew Road',
          address_line3: 'Knowtown',
          postcode: nil,
          country: 'GB',
        )
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__value .govuk-link').to_html).not_to include('Enter phone number')
        expect(result.css('.govuk-summary-list__value .govuk-link').to_html).not_to include('Enter address')
        expect(result.css('.govuk-summary-list__value .govuk-link').to_html).to include('Enter postcode')
      end
    end

    it 'renders the address fields that are not empty strings' do
      application_form = build(
        :application_form,
        phone_number: '07700 900 982',
        address_line1: '42 <script>Much</script> Wow Street',
        address_line2: '',
        address_line3: 'London',
        address_line4: 'England',
        postcode: 'SW1P 3BT',
      )

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__value').to_html).to include('42 &lt;script&gt;Much&lt;/script&gt; Wow Street<br role="presentation">London<br role="presentation">England<br role="presentation">SW1P 3BT')
    end
  end

  context 'when contact details are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form:, editable: false))

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
    end
  end
end
