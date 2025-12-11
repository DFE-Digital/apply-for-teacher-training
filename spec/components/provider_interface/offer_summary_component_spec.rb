require 'rails_helper'

RSpec.describe ProviderInterface::OfferSummaryComponent do
  include Rails.application.routes.url_helpers

  let(:application_choice) do
    create(:application_choice,
           :offered,
           offer: build(:offer, conditions:, ske_conditions:),
           school_placement_auto_selected:)
  end
  let(:school_placement_auto_selected) { false }
  let(:conditions) { [build(:text_condition, description: 'condition 1')] }
  let(:ske_conditions) { [] }
  let(:course_option) { build(:course_option, course:) }
  let(:providers) { [] }
  let(:course) { build(:course, funding_type: 'fee') }
  let(:courses) { [] }
  let(:course_options) { [] }
  let(:editable) { true }
  let(:show_recruit_pending_button) { false }
  let(:render) do
    render_inline(described_class.new(application_choice:,
                                      course_option:,
                                      conditions: application_choice.offer.conditions,
                                      ske_conditions: application_choice.offer.ske_conditions,
                                      available_providers: providers,
                                      available_courses: courses,
                                      available_course_options: course_options,
                                      course:,
                                      editable:,
                                      show_recruit_pending_button:))
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

  context 'when school placement is auto selected' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }
    let(:school_placement_auto_selected) { true }

    it 'does not render the location row' do
      expect(render).to have_no_content('Location')
    end
  end

  context 'when school placement is candidate selected' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }

    it 'renders the location row' do
      expect(render).to have_content('Location')
    end
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.full_address("\n"))
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
    expect(row_text_selector(:qualification, render)).to include('QTS with PGCE')
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
      let(:conditions) { [build(:text_condition, :met)] }

      it 'renders conditions as met' do
        expect(render.css('#offer-conditions-list .govuk-summary-list__row .govuk-summary-list__key')[0].text.squish).to eq(conditions.first.text)
        expect(render.css('#offer-conditions-list .govuk-summary-list__row .govuk-tag')[0].text).to eq('Met')
      end
    end

    context 'when status is set to unmet' do
      let(:conditions) { [build(:text_condition, :unmet)] }

      it 'renders conditions as met' do
        expect(render.css('#offer-conditions-list .govuk-summary-list__row .govuk-summary-list__key')[0].text.squish).to eq(conditions.first.text)
        expect(render.css('#offer-conditions-list .govuk-summary-list__row .govuk-tag')[0].text).to eq('Not met')
      end
    end

    context 'when status is set to pending' do
      let(:conditions) { [build(:text_condition, :pending)] }

      it 'renders conditions as met' do
        expect(render.css('#offer-conditions-list .govuk-summary-list__row .govuk-summary-list__key')[0].text.squish).to eq(conditions.first.text)
        expect(render.css('#offer-conditions-list .govuk-summary-list__row .govuk-tag')[0].text).to eq('Pending')
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
          expect(render.css('.govuk-body').css("a[href='#{edit_provider_interface_condition_statuses_path(application_choice)}']").text).to eq('Update status of conditions')
        end
      end

      context 'when application is in conditions_pending state but only SKE conditions are pending and when `show_recruit_pending_button` option is false' do
        let(:application_choice) { build_stubbed(:application_choice, :accepted) }

        before { allow(CanRecruitWithPendingConditions).to receive(:new).and_return(instance_double(CanRecruitWithPendingConditions, call: true)) }

        it 'displays the update condition link and no recruit with pending button' do
          expect(render.css('.govuk-body').css("a[href='#{edit_provider_interface_condition_statuses_path(application_choice)}']").text).to eq('Update status of conditions')
          expect(render.css('.govuk-body').css("form[action='#{new_provider_interface_application_choice_offer_recruit_with_pending_conditions_path(application_choice_id: application_choice.id)}']")).to be_blank
        end
      end

      context 'when application is in conditions_pending state but only SKE conditions are pending and when `show_recruit_pending_button` option is true' do
        let(:application_choice) { build_stubbed(:application_choice, :accepted) }
        let(:show_recruit_pending_button) { true }

        before { allow(CanRecruitWithPendingConditions).to receive(:new).and_return(instance_double(CanRecruitWithPendingConditions, call: true)) }

        it 'displays the update condition button and recruit with pending button' do
          expect(render.css('.govuk-body').css("a[href='#{edit_provider_interface_condition_statuses_path(application_choice)}']")).to be_blank
          expect(render.css('.govuk-body').css("form[action='#{new_provider_interface_application_choice_offer_recruit_with_pending_conditions_path(application_choice_id: application_choice.id)}']")).to be_present
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
      let(:ske_conditions) { [build(:ske_condition)] }
      let(:conditions) { [] }

      it 'renders the SKE conditions' do
        expect(render).to have_content('Subject knowledge enhancement course')
      end
    end
  end
end
