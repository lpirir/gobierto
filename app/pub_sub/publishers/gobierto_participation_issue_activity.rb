module Publishers
  class GobiertoParticipationIssueActivity
    include Publisher
    self.pub_sub_namespace = 'activities/gobierto_participation_issues'
  end
end