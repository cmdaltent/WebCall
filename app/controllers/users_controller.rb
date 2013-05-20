class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  
  before_filter :is_signed_in, only: [:edit, :update, :index,:show,:destroy]
  before_filter :is_correct_user, only: [:edit, :update,:destroy]
  
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    #respond_to do |format|
     # format.html # show.html.erb
      #format.json { render json: @user }
    #end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    #respond_to do |format|
     # format.html # new.html.erb
     # format.json { render json: @user }
    #end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    if @user.save
        sign_in @user
        flash[:success] = "Have a nice web_call_travelling!"
        redirect_to @user
      else
        render 'new'
      end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        sign_in @user
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "Success destroyed."
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  private
  
  def is_signed_in
    unless signin?
      redirect_to signin_path, notice: "Please sign in." 
    end
  end
  
  def is_correct_user
      @user = User.find(params[:id])
      redirect_to users_path, notice:"You cann't do this for others." unless current_user ==(@user)
  end
  
end
