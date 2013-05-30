class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  
  before_filter :authenticated_user, only: [:index,:show]
  before_filter :authorized_user, only: [:edit, :update,:destroy]
  
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  def create(name,pass,pass_confirm)
    @user = User.new do |f|
      f.username = name
      f.password = pass
      f.password_confirmation = pass_confirm
      f.save
    end
  end
  
  
  def is_authenticated_user(login_email,login_pass )
    transaction do
      User.find(:first,:condition => ["name=? and password=?",login_email,login_pass])
    end
  end
  
  def get_pwdsalt(login_name)
    transaction do
       User.find(:first,:conditions=>["name=?",login_email]).password_confirmation
    end
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
   
  def authorized_user
      # puts "User id:" + params[:id].to_s + "======\n"
      @user = User.find(params[:id])
      redirect_to users_path,notice:"You cann't eidt Info of others." unless current_user == @user
  end
  
end
