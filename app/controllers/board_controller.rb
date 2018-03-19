class BoardController < ApplicationController
  default_search_scope :issues

  before_filter :find_projects, :authorize, :only => :index

  include BoardQueriesHelper
  include BoardsHelper
  include BoardHelper

  helper :journals
  helper :projects
  helper :custom_fields
  helper :issue_relations
  helper :watchers
  helper :attachments
  helper :queries
  helper :repositories
  helper :timelog

  IN_PROGRESS_STATUS_CODE = 1
  RESOLVED_STATUS_CODE    = 2

  def find_projects
    # @project variable must be set before calling the authorize filter
    @projects = User.current.projects.to_a
  end

  def index
    retrieve_query

    if @query.valid?
      respond_to do |format|
        format.html {
          @issue_count = @query.issue_count
          @issue_pages = Paginator.new @issue_count, per_page_option, params['page']
          @issues      = @query.issues(:offset => @issue_pages.offset, :limit => @issue_pages.per_page)

          render :layout => !request.xhr?
        }
      end
    else
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
        format.any(:atom, :csv, :pdf) { head 422 }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def will_do_today
    @issue            = Issue.find(params[:id])
    issue_status_name = settings_today_time_status_name
    issue_status      = IssueStatus.find_by_name(issue_status_name)

    if issue_status
      @issue.status_id      = issue_status.id
      @issue.assigned_to_id = User.current.id
      @issue.custom_field_values.each do |field|
        if field.custom_field.name == settings_today_time_field_name
          field.value = params[:time]
        end
      end

      @issue.save(:validate => true)

      errors        = @issue.errors.full_messages
      is_successful = errors.empty?
    else
      errors        = l(:notification_no_status_today_time)
      is_successful = false
    end

    render :json => {
        :success          => is_successful,
        :errors           => errors,
        :info             => l(:notification_issue_updated),
        :status           => issue_status_name,
        :today_time_value => get_user_total_today_time,
        :assignee         => User.current.name
    }
  end

  def update_status
    @issue            = Issue.find(params[:id])
    status_code       = params[:status].to_f
    issue_status_name = status_code == IN_PROGRESS_STATUS_CODE ? settings_in_progress_status_name : settings_resolved_status_name
    issue_status      = IssueStatus.find_by_name(issue_status_name)

    if issue_status
      @issue.status_id      = issue_status.id
      @issue.assigned_to_id = User.current.id
      @issue.save(:validate => true)

      errors        = @issue.errors.full_messages
      is_successful = errors.empty?
    else
      errors        = l(:notification_no_status_today_time)
      is_successful = false
    end

    render :json => {
        :success          => is_successful,
        :errors           => errors,
        :info             => l(:notification_issue_updated),
        :status           => issue_status_name,
    }
  end

  def update_time_for_today
    @issue        = Issue.find(params[:id])
    is_changed    = false
    errors        = []
    is_successful = true

    @issue.custom_field_values.each do |field|
      if field.custom_field.name == settings_today_time_field_name
        field.value = params[:time]
        is_changed  = field.value_was != field.value && field.value.to_f != 0
      end
    end

    if is_changed
      @issue.save(:validate => true)

      errors        = @issue.errors.full_messages
      is_successful = errors.empty?
    end

    render :json => {
        :success          => is_successful,
        :is_changed       => is_changed,
        :errors           => errors,
        :info             => l(:notification_time_updated),
        :today_time_value => get_user_total_today_time
    }
  end
end
