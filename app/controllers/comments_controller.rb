class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    
    if user_signed_in?
      @comment.user = current_user
    else 
      @comment.user = User.find_by(email: 'test@test.com') 
    end

    respond_to do |format|
      if @comment.save
        # Aici e magia Turbo:
        format.turbo_stream
        # Backup pentru browserele care nu suportă Turbo sau cereri normale:
        format.html { redirect_to root_path, notice: "Comentariul a fost adăugat!" }
      else
        format.html { redirect_to root_path, alert: "Eroare la adăugarea comentariului." }
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end