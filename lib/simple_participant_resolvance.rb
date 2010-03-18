class SimpleParticipantResolvance
  def participant_contains?(participant_definition, participant)
    if participant_definition == "normal_employee"
      return !(participant =~ /^manager/)
    end 
  end
end