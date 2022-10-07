require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncSubjects, sidekiq: true do
  include TeacherTrainingPublicAPIHelper
  describe '.perform' do
    context 'creates or updates subject entries given the subject code' do
      before do
        stub_teacher_training_api_subjects([{ type: 'subjects', code: '00', name: 'Primary' },
                                            { type: 'subjects', code: '01', name: 'Japanese' },
                                            { type: 'subjects', code: '02', name: 'German' },
                                            { type: 'subjects', code: '22', name: 'Spanish' }])
      end

      it 'creates any non existing entries' do
        expect { described_class.new.perform }.to change { Subject.count }.by(4)
      end

      it 'updates any existing entries' do
        create(:subject, code: '00', name: 'Other name')
        create(:subject, code: '02', name: 'To update')

        described_class.new.perform

        expect(Subject.count).to eq(4)
        expect(Subject.find_by(code: '00').name).to eq('Primary')
        expect(Subject.find_by(code: '02').name).to eq('German')
      end
    end
  end
end
