class SessionsController < ApplicationController
  def new
  end

  def create
    # Find user by email
    user = User.find_by(email: params[:session][:email].downcase)

    # Authenticate user
    if user && user.authenticate(params[:session][:password])
      # Log in user

      flash[:success] = "Welcome to the Sample App!"
      log_in user
      redirect_to user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new", status: :unprocessable_entity

    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  private
end
