require 'rails_helper'

RSpec.describe ProviderInterface::OfferSummaryComponent do
  include Rails.application.routes.url_helpers

  let(:application_choice) do
    build_stubbed(:application_choice,
                  :offered,
                  offer: build(:offer, conditions:))
  end
  let(:conditions) { [build(:offer_condition, text: 'condition 1')] }
  let(:course_option) { build_stubbed(:course_option, course:) }
  let(:providers) { [] }
  let(:course) { build_stubbed(:course, funding_type: 'fee') }
  let(:courses) { [] }
  let(:course_options) { [] }
  let(:editable) { true }
  let(:wizard) { nil }
  let(:render) do
    render_inline(described_class.new(application_choice:,
                                      course_option:,
                                      conditions: application_choice.offer.conditions,
                                      available_providers: providers,
                                      available_courses: courses,
                                      available_course_options: course_options,
                                      course:,
                                      editable:,
                                      wizard:))
  end

  def row_text_selector(row_name, render)
    rows = if course.accredited_provider.nil?
             {
               provider: 0,
               course: 1,
               full_or_part_time: 2,
               location: 3,
               qualification: 4,
               funding_type: 5,
             }
           else
             {
               provider: 0,
               course: 1,
               full_or_part_time: 2,
               location: 3,
               accredited_provider: 4,
               qualification: 5,
               funding_type: 6,
             }
           end

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  def row_link_selector(row_number)
    render.css('.govuk-summary-list__row')[row_number].css('a')&.first&.attr('href')
  end

  context 'when multiple provider options' do
    let(:providers) { build_stubbed_list(:provider, 2) }

    it 'renders a change link' do
      provider_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_providers_path(application_choice)
      expect(row_link_selector(0)).to eq(provider_change_link)
    end
  end

  context 'when only one provider option' do
    let(:providers) { [build_stubbed(:provider)] }

    it 'renders no change link' do
      expect(row_link_selector(0)).to be_nil
    end
  end

  context 'when multiple courses' do
    let(:courses) { build_stubbed_list(:course, 2) }

    it 'renders a change link' do
      course_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_courses_path(application_choice)
      expect(row_link_selector(1)).to eq(course_change_link)
    end
  end

  context 'when only one course' do
    let(:courses) { [build_stubbed(:course)] }

    it 'renders no change link' do
      expect(row_link_selector(1)).to be_nil
    end
  end

  context 'when multiple course options' do
    let(:course_options) { build_stubbed_list(:course_option, 2) }

    it 'renders a change link' do
      course_options_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_locations_path(application_choice)
      expect(row_link_selector(3)).to eq(course_options_change_link)
    end
  end

  context 'when only one course option' do
    let(:course_options) { [build_stubbed(:course_option)] }

    it 'renders no change link' do
      expect(row_link_selector(3)).to be_nil
    end
  end

  context 'when multiple study modes' do
    let(:course) { build_stubbed(:course, study_mode: :full_time_or_part_time) }

    it 'renders a change link' do
      study_mode_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_study_modes_path(application_choice)
      expect(row_link_selector(2)).to eq(study_mode_change_link)
    end
  end

  context 'when only one study mode' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }

    it 'renders no change link' do
      expect(row_link_selector(2)).to be_nil
    end
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.full_address("\n"))
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
    expect(row_text_selector(:qualification, render)).to include('PGCE with QTS')
    expect(row_text_selector(:funding_type, render)).to include(course_option.course.funding_type.humanize)
  end

  context 'when the accredited provider is not the same as the training provider' do
    let(:course) { build_stubbed(:course, :with_accredited_provider) }
    let(:course_option) { build_stubbed(:course_option, course:) }

    it 'renders an extra row with the accredited provider details' do
      expect(row_text_selector(:accredited_provider, render)).to include(course.accredited_provider.name_and_code)
    end
  end

  context 'when conditions are set' do
    context 'when status is set to met' do
      let(:conditions) { [build(:offer_condition, :met)] }

      it 'renders conditions as met' do
        expect(render.css('.app-conditions-list .govuk-summary-list__row .govuk-summary-list__key')[0].text.squish).to eq(conditions.first.text)
        expect(render.css('.app-conditions-list .govuk-summary-list__row .govuk-tag')[0].text).to eq('Met')
      end
    end

    context 'when status is set to unmet' do
      let(:conditions) { [build(:offer_condition, :unmet)] }

      it 'renders conditions as met' do
        expect(render.css('.app-conditions-list .govuk-summary-list__row .govuk-summary-list__key')[0].text.squish).to eq(conditions.first.text)
        expect(render.css('.app-conditions-list .govuk-summary-list__row .govuk-tag')[0].text).to eq('Not met')
      end
    end

    context 'when status is set to pending' do
      let(:conditions) { [build(:offer_condition, :pending)] }

      it 'renders conditions as met' do
        expect(render.css('.app-conditions-list .govuk-summary-list__row .govuk-summary-list__key')[0].text.squish).to eq(conditions.first.text)
        expect(render.css('.app-conditions-list .govuk-summary-list__row .govuk-tag')[0].text).to eq('Pending')
      end
    end
  end

  describe '#editable' do
    context 'when true' do
      let(:editable) { true }

      context 'when application is in offer state' do
        let(:application_choice) { build_stubbed(:application_choice, :offered) }

        it 'displays the conditions change link' do
          expect(render.css('.govuk-body').css('a').first.attr('href')).to eq(new_provider_interface_application_choice_offer_conditions_path(application_choice))
        end
      end

      context 'when application is in condititions_pending state' do
        let(:application_choice) { build_stubbed(:application_choice, :accepted) }

        it 'displays the update condition link' do
          expect(render.css('.govuk-body').css('a').first.attr('href')).to eq(edit_provider_interface_condition_statuses_path(application_choice))
        end
      end
    end

    context 'when false' do
      let(:editable) { false }

      it 'does not display any change links' do
        expect(render.css('.govuk-body').css('a').first).to be_nil
      end
    end

    context 'when SKE eligible' do
      before do
        FeatureFlag.activate(:provider_ske)
      end

      let(:wizard) do
        instance_double(
          ProviderInterface::OfferWizard,
          ske_length:,
          ske_reason:,
        )
      end

      context 'when on the standard flow' do
      end

      context 'when on the languages flow' do
      end
    end
  end
end
