require 'rails_helper'

RSpec.describe ApplicationHelper do
  # rubocop:disable RSpec/AnyInstance
  describe '#service_key' do
    it 'is apply for candidate_interface namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('candidate_interface')
      expect(service_key).to eq('apply')
    end

    it 'is manage for provider_interface namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('provider_interface')
      expect(service_key).to eq('manage')
    end

    it 'is support for support_interface namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('support_interface')
      expect(service_key).to eq('support')
    end

    it 'is api for api_docs namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('api_docs')
      expect(service_key).to eq('api')
    end

    it 'is apply for nil namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return(nil)
      expect(service_key).to eq('apply')
    end
  end
  # rubocop:enable RSpec/AnyInstance

  describe '#markdown' do
    it 'converts markdown to HTML' do
      expect(helper.markdown('test')).to eq('<p class="govuk-body">test</p>')
    end

    it 'converts markdown lists to HTML lists' do
      expect(helper.markdown("* test\n* another test")).to include('<li>test</li>')
    end

    it 'converts bullets into HTML lists' do
      output = helper.markdown("* test\n• bullet\n•bullet without space")

      expect(output).to include('<li>test</li>')
      expect(output).to include('<li>bullet</li>')
      expect(output).to include('<li>bullet without space</li>')
    end

    it 'converts markdown lists into HTML when space missed between * and word' do
      output = helper.markdown("* test\n*no space here\n*also *here*")

      expect(output).to include('<li>test</li>')
      expect(output).to include('<li>no space here</li>')
      expect(output).to include('<li>also *here*</li>')
    end

    it 'ignores emphasis markdown' do
      output = helper.markdown("This does not have *emphasis*\n**something important**\n***super***")
      expect(output).to include('This does not have *emphasis*')
      expect(output).to include('**something important**')
      expect(output).to include('***super***')
    end

    it 'converts quotes to smart quotes' do
      output = helper.markdown("\"Wow – what's this...\", O'connor asked.")
      expect(output).to eq('<p class="govuk-body">“Wow – what’s this…”, O’connor asked.</p>')
    end

    # Redcarpet fixes out of the box
    it 'fixes incorrect markdown links' do
      output = helper.markdown('[Google] (https://www.google.com)')
      expect(output).to include('<a href="https://www.google.com" class="govuk-link">Google</a>')
    end
  end

  describe '#smart_quotes' do
    it 'converts quotes to smart quotes' do
      output = helper.smart_quotes("\"Wow – what's this...\", O'connor asked.")
      expect(output).to include('“Wow – what’s this…”, O’connor asked.')
    end

    it 'does not convert three consecutive dashes to an em dash' do
      output = helper.smart_quotes('https://www.londonmet.ac.uk/courses/postgraduate/pgce-secondary-science-with-biology---pgce')
      expect(output).to include('https://www.londonmet.ac.uk/courses/postgraduate/pgce-secondary-science-with-biology---pgce')
    end

    context 'when nil' do
      it 'returns empty string' do
        expect(helper.smart_quotes(nil)).to be_blank
      end
    end
  end
end
