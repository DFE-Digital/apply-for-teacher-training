desc 'Fix audit records that refer to a provider email rather than provider ID'
task fix_provider_audits: :environment do
  FixProviderAudits.new.call
end
