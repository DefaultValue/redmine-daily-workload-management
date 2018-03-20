module BoardHelper
  def get_total_for_today(issue)
    real      = ''
    suggested = 0
    issue.custom_field_values.each do |field|
      if field.custom_field.name == settings_today_time_field_name
        if field.value.nil? || field.value.to_f == 0.0
          suggested = issue.estimated_hours.to_f - issue.spent_hours.to_f
          suggested = suggested < 0 ? 0 : suggested
        else
          real = suggested = field.value.to_f
        end
      end
    end

    @real_time      = real
    @suggested_time = suggested.round(2)
  end

  def settings_today_time_field_name
    (Setting.plugin_daily_workload_management && Setting.plugin_daily_workload_management.include?('field')) ? Setting.plugin_daily_workload_management['field'] : ''
  end

  def settings_today_time_status_name
    (Setting.plugin_daily_workload_management && Setting.plugin_daily_workload_management.include?('status')) ? Setting.plugin_daily_workload_management['status'] : ''
  end

  def settings_resolved_status_name
    (Setting.plugin_daily_workload_management && Setting.plugin_daily_workload_management.include?('settings_resolved_status')) ? Setting.plugin_daily_workload_management['settings_resolved_status'] : ''
  end

  def settings_in_progress_status_name
    (Setting.plugin_daily_workload_management && Setting.plugin_daily_workload_management.include?('settings_in_progress_status')) ? Setting.plugin_daily_workload_management['settings_in_progress_status'] : ''
  end

  def get_user_total_today_time
    today_status    = IssueStatus.find_by_name(settings_today_time_status_name)
    total_for_today = 0

    if today_status.nil?
      return total_for_today
    end

    current_user = User.current
    if current_user.nil?
      return total_for_today
    end

    total_for_today = ActiveRecord::Base.connection.execute("
    SELECT
      SUM(custom_values.value)                                                     AS h_t,
      SUM(CASE WHEN p_statuses.id IS NOT NULL THEN custom_values.value ELSE 0 END) AS h_p
    FROM issues
      INNER JOIN custom_values ON issues.id = custom_values.customized_id
      LEFT JOIN issue_statuses AS p_statuses ON issues.status_id = p_statuses.id AND
                                                p_statuses.name = #{ActiveRecord::Base.sanitize(settings_today_time_status_name)}
    WHERE issues.assigned_to_id = #{current_user.id}
          AND custom_values.custom_field_id = #{IssueCustomField.find_by_name(settings_today_time_field_name).id};
    ").to_a[0]

    @time_total    = (total_for_today[0].nil? ? 0 : total_for_today[0]).round(2)
    @time_pipeline = (total_for_today[1].nil? ? 0 : total_for_today[1]).round(2)
  end
end
