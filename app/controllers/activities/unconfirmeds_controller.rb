module Activities
  class UnconfirmedsController < ApplicationController
    def show
      @activities = Activity.unconfirmed.includes(:user).paginate(page: params[:per_page])
    end
  end
end