class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    
    if user_signed_in?
        @comment.user = current_user
    else 
        @comment.user = User.find_by(email: 'test@test.com') 
    end

    if @comment.save
        redirect_to posts_path, notice: "Comentariul a fost adăugat!"
    else
        redirect_to posts_path, alert: "Eroare la adăugarea comentariului."
    end
end

def comment_params
    params.require(:comment).permit(:content)
  end
end