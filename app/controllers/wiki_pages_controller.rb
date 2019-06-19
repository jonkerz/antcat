class WikiPagesController < ApplicationController
  before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:index, :show]
  before_action :ensure_user_is_superadmin, only: :destroy
  before_action :set_wiki_page, only: [:show, :edit, :update, :destroy]

  def index
    @wiki_pages = WikiPage.order(:title).paginate(page: params[:page], per_page: 30)
  end

  def show
  end

  def new
    @wiki_page = WikiPage.new
  end

  def edit
  end

  def create
    @wiki_page = WikiPage.new(wiki_page_params)

    if @wiki_page.save
      @wiki_page.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to @wiki_page, notice: "Successfully created wiki page."
    else
      render :new
    end
  end

  def update
    if @wiki_page.update(wiki_page_params)
      @wiki_page.create_activity :update, edit_summary: params[:edit_summary]
      redirect_to @wiki_page, notice: "Successfully updated wiki page."
    else
      render :edit
    end
  end

  def destroy
    @wiki_page.destroy
    @wiki_page.create_activity :destroy, edit_summary: params[:edit_summary]
    redirect_to wiki_pages_path, notice: "Wiki page was successfully deleted."
  end

  def autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteWikiPages[search_query]
      end
    end
  end

  private

    def set_wiki_page
      @wiki_page = WikiPage.find(params[:id])
    end

    def wiki_page_params
      params.require(:wiki_page).permit(:title, :content)
    end
end
