class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  skip_before_action :set_user_info, only: %i[new create]
  before_action :forbid_login_user, only: %i[new]

  def new
  end

  def create
    @user = login(params[:email], params[:password])
    if @user
      redirect_to running_records_path
      flash[:success] = t(".success")
    else
      flash.now[:danger] = t(".fail")
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path
    flash[:success] = t(".success")
  end
end
