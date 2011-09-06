# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_current_user

  def current_user
    # TODO: transition this out in favor of @current_user
    ActiveSupport::Deprecation.warn "current_user is deprecated in favor of @current_user", caller
    @current_user
  end

  # Puts a flash[:notice] error message and redirects if condition isn't true.
  # Returns true if redirected.
  #
  # Usage: return if redirected_because(!user_logged_in, "Not logged in!", "/diaf")
  #
  def redirected_because(condition=true, error_msg="Error!", redirect_url=nil)
    return false if condition == false or redirect_url.nil?
    flash[:error] = error_msg
    redirect_to redirect_url unless redirect_url.nil?
    return true
  end



####################
#     FILTERS      #
####################

  # Only the user to whom the job belongs is permitted to view the particular
  # action for this job.
  def view_ok_for_unactivated_job
    j = Job.find(params[:id].present? ? params[:id] : params[:job_id])
      # id and job_id because this filter is used by both the JobsController
      # and the ApplicsController
    if (j == nil || ! j.active && @current_user != j.user)
      flash[:error] = "Unauthorized access denied. Do not pass Go. Do not collect $200."
      redirect_to :controller => 'dashboard', :action => :index
    end
  end

  # Only users other than the user to whom the job belongs is permitted to watch
  # or apply to the job.
  def watch_apply_ok_for_job
    j = Job.find(params[:id].present? ? params[:id] : params[:job_id])
      # id and job_id because this filter is used by both the JobsController
      # and the ApplicsController
    if (j == nil || @current_user == j.user)
      flash[:error] = "You cannot watch or apply to your own listing."
      redirect_to job_path(j)
    end
  end

  private

  def set_current_user
    @user_session = UserSession.find
    @current_user = @user_session ? @user_session.user : nil
  end

end
