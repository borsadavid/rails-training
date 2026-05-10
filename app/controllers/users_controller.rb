class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User created successfully! 🚀"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User updated successfully! ✨"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User deleted successfully! 🗑️", status: :see_other
  end

  private

  # Metodă helper pentru a evita repetiția User.find(params[:id])
  def set_user
    @user = User.find(params[:id])
  end

  # Strong Parameters
  def user_params
    params.require(:user).permit(:name, :email, :birthday)
  end
end