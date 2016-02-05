module Api::V1
  class AuthorsController < Api::ApiController
    def index
      authors = Author.all
      render json: authors, status: :ok

    end


    def show
      begin
        authors = Author.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end
      render json: authors, status: :ok
    end

  end
end