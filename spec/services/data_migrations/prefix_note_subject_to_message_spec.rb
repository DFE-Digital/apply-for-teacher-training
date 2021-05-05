require 'rails_helper'

RSpec.describe DataMigrations::PrefixNoteSubjectToMessage do
  let!(:note) { create(:note, subject: 'Marvel', message: 'Avengers Assemble') }

  it 'appends the note subject to the message' do
    described_class.new.change

    expect(note.reload.message.to_s).to eq(%(Subject: Marvel\r\n\r\nAvengers Assemble))
  end

  it 'does not update the application_choice timestamps' do
    application_choice_created_at = note.application_choice.created_at
    application_choice_updated_at = note.application_choice.updated_at

    described_class.new.change

    expect(note.application_choice.created_at).to eq(application_choice_created_at)
    expect(note.application_choice.updated_at).to eq(application_choice_updated_at)
  end

  it 'does not update the audit log' do
    application_choice_created_at = note.application_choice.created_at
    application_choice_updated_at = note.application_choice.updated_at

    expect { described_class.new.change }.not_to(change { Audited::Audit.count })

    expect(note.application_choice.created_at).to eq(application_choice_created_at)
    expect(note.application_choice.updated_at).to eq(application_choice_updated_at)
  end
end
