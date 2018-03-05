module WorkloadManagementSettingsHelper
  def time_for_today_required_statuses
    allStatuses = IssueStatus.all.sorted
  end

  def issue_custom_fields
    allIssueCustomFields = IssueCustomField.all.sorted
  end
end
