class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    @comment.save
    redirect_to trip_path(params[:trip_id])
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to trip_path(params[:trip_id])
  end

  private

  def comment_params
    params.require(:comment).permit(:id, :content, :created_at).merge(user_id: current_user.id, trip_id: params[:trip_id])
  end
end
