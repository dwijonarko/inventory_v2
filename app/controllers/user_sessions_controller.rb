class UserSessionsController < ApplicationController
  layout 'login'
  def new
    @company = Company.find_by_subdomain(current_subdomain)
    @user_session = @company.user_sessions.new(:subdomain => current_subdomain)
  end
  
  def create
    @company = Company.find_by_subdomain(current_subdomain)
    @user_session = @company.user_sessions.new(params[:user_session])
    if @user_session.save
      flash[:success] = "Welcome #{current_user.username}"
      redirect_to root_url
    else
      flash[:error] = "Invalid username or password"
      render :action => 'new'
    end
  end
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy unless @user_session.nil?
    flash[:notice] = "You're signed out ."
    redirect_to signin_url
  end

end
