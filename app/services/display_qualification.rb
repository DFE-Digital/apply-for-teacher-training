class DisplayQualification
  def self.call(qualification:)
    case qualification
    when 'qts'
      'QTS'
    when 'pgce'
      'PGCE'
    when 'pgde'
      'PGDE'
    when 'pgce_with_qts'
      'PGCE with QTS'
    when 'pgde_with_qts'
      'PGDE with QTS'
    end
  end
end
