require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.changed_offer' do
    let(:email) { described_class.changed_offer(application_choices.first) }
    let(:provider) { build_stubbed(:provider, name: 'Brighthurst Technical College') }
    let(:course) { build_stubbed(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider:) }
    let(:course_option) { build_stubbed(:course_option, course:) }

    let(:other_provider) { build_stubbed(:provider, name: 'Falconholt Technical College', code: 'X100') }
    let(:other_course) { build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: other_provider) }
    let(:other_option) { build_stubbed(:course_option, course: other_course, site: build_stubbed(:site, name: 'Aquaria')) }

    let(:offer) { build_stubbed(:offer, conditions: [build_stubbed(:text_condition, description: 'Gain experience working with children')]) }

    before { application_form }

    context 'an unconditional offer' do
      let(:application_choices) do
        [build_stubbed(:application_choice,
                       :course_changed_after_offer,
                       course_option:,
                       current_course_option: other_option,
                       offer: build_stubbed(:unconditional_offer))]
      end

      it_behaves_like(
        'a mail with subject and content',
        'Offer changed for Applied Science (Psychology) (3TT5)',
        'heading' => 'Hello Fred',
        'name for original course' => 'Applied Science (Psychology)',
        'name for new course' => 'Course: Forensic Science (E0FO)',
        'name of new provider' => 'Training provider: Falconholt Technical College',
        'location of new offer' => 'Location: Aquaria',
        'study mode of new offer' => 'Full time',
        'unconditional' => 'Your offer does not have any conditions',
      )
    end

    context 'an offer with conditions' do
      let(:application_choices) do
        [build_stubbed(:application_choice,
                       :course_changed_after_offer,
                       offer:,
                       course_option:,
                       current_course_option: other_option)]
      end

      it_behaves_like(
        'a mail with subject and content',
        'Offer changed for Applied Science (Psychology) (3TT5)',
        'heading' => 'Hello Fred',
        'name for original course' => 'Applied Science (Psychology)',
        'name for new course' => 'Course: Forensic Science (E0FO)',
        'name of new provider' => 'Training provider: Falconholt Technical College',
        'location of new offer' => 'Location: Aquaria',
        'study mode of new offer' => 'Full time',
        'first condition' => 'Gain experience working with children',
      )
    end
  end
end
