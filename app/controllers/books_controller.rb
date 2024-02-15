class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource
  include Pagy::Backend

  def index
    #@books = search_books
    #@pagy, @books = pagy(@books)
        @pagy, @books = pagy(search_books)

  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create

    @book = current_user.books.new(book_params) if current_user.author?

    if @book.save
      redirect_to books_path, notice: 'Book was successfully created.'
    else
      render :new
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    if @book.update(book_params)
      redirect_to books_path, notice: 'Book was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path, notice: 'Book was successfully destroyed.'
  end

  private

  def book_params
    params.require(:book).permit(:title, :author_id, :admin_id)
  end

  def set_book
    @book = Book.find(params[:id])
  end

  def search_books
    if params[:query].present?
      Book.where('title LIKE ?', "%#{params[:query]}%")
    else
      current_user.admin? ? Book.all : current_user.books
    end
  end
end
