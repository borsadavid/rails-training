class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    # Prevenim like-ul multiplu
    @post.likes.create(user: current_user) unless @post.likes.where(user: current_user).any?
    
    redirect_back fallback_location: posts_path
  end

  def destroy
    @post = Post.find(params[:post_id])
    @like = @post.likes.find_by(user: current_user)
    @like&.destroy
    
    redirect_back fallback_location: posts_path
  end
end