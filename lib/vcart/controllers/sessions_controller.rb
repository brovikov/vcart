# encoding: utf-8
class SessionsController < ApplicationController
  def new
    redirect_to root_url if current_user
  end


  def create

    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      user.update_attribute(:login_at, Time.zone.now)
      user.update_attribute(:ip_address, request.remote_ip)
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
     

        
      else
        cookies[:auth_token] = { :value => user.auth_token }

 #httponly: true, :expires => 1.year.from_now
      end
      redirect_to root_url #, :notice => "Logado!"
    else
      flash.now[:alert] = "Email ou Password inválido"
      render :new
    end
  end





  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url
    current_user = nil
  end
end
