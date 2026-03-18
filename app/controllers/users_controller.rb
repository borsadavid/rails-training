class UsersController < ApplicationController

    def index
        @users = User.all

    end

    def show
    @user = User.find_by(id: params[:id]) 

    end

    def destroy
        user = User.find(params[:id])
        user.destroy
        redirect_to users_path
    end

    def new
end

def create
  user = User.new(
        name: params[:name],
        email: params[:email],
        birthday: params[:birthday]
  )

    if user.save
       redirect_to users_path
     else
       render :new
  end

def show
  @user = User.find(params[:id])
end

def update
    user = User.find(params[:id])

    user.update(
        name: params[:name],
        email: params[:email]
    )

    redirect_to users_path
    end
end
end
