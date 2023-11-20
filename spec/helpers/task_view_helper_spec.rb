require 'rails_helper'

RSpec.describe TaskViewHelper do
  let(:application_choices) do
    ProviderInterface::SortApplicationChoices.call(application_choices: ApplicationChoice.all)
  end
  let(:choice) { application_choices.find(id) }

  describe '#display_header?' do
    let!(:inactive) { create(:application_choice, :inactive) }
    let!(:second_inactive) { create(:application_choice, :inactive) }

    context 'when the choice is the first of type in the collection' do
      let(:id) { inactive.id }

      it 'returns true' do
        actual = helper.display_header?(application_choices, choice)
        expect(actual).to be(true)
      end
    end

    context 'when the choice is the second of type in the collection' do
      let(:id) { second_inactive.id }

      it 'returns false' do
        actual = helper.display_header?(application_choices, choice)
        expect(actual).to be(false)
      end
    end
  end

  describe '#task_view_header' do
    context 'inactive applications yield the correct heading' do
      let(:id) { create(:application_choice, :inactive).id }

      it 'yields the heading' do
        expect { |b| helper.task_view_header(choice, &b) }.to yield_with_args('Received over 30 days ago - make a decision now')
      end
    end

    context 'awaiting_decision applications yield the correct heading' do
      let(:id) { create(:application_choice, :awaiting_provider_decision).id }

      it 'yields the heading' do
        expect { |b| helper.task_view_header(choice, &b) }.to yield_with_args('Received – make a decision')
      end
    end
  end

  describe '#task_view_subheader' do
    context 'inactive applications yield the correct heading' do
      let(:id) { create(:application_choice, :inactive).id }

      it 'yields the subheading' do
        expect { |b| helper.task_view_subheader(choice, &b) }.to yield_with_args('You received these applications over 30 working days ago. You need to make a decision as soon as possible or the candidate may choose to withdraw and apply to another provider.')
      end
    end

    context 'awaiting_decision applications yield the correct heading' do
      let!(:id) { create(:application_choice, :awaiting_provider_decision).id }

      it 'does not yields the subheading' do
        expect { |b| helper.task_view_subheader(choice, &b) }.not_to yield_control
      end
    end
  end

  describe '#relative_date_text_class' do
    context 'inactive applications' do
      let(:id) { create(:application_choice, :inactive).id }

      it 'returns the CSS class' do
        expect(helper.relative_date_text_color(choice)).to eq('app-status-indicator--red')
      end
    end

    context 'non-inactive applications' do
      let(:id) { create(:application_choice, :awaiting_provider_decision).id }

      it 'returns ""' do
        expect(helper.relative_date_text_color(choice)).to eq('')
      end
    end
  end
end
