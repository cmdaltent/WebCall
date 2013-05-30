class MeetingsController < ApplicationController

  before_filter :authenticated_user, only: [:index,:new]
  before_filter :authorized_users, only:[:index,:show,:edit,:update,:destroy]
  
  # GET /meetings
  # GET /meetings.json
  def index
    current_time = get_current_time_since_unix
    defaults = {:onlyUpcoming => "true", :meOrganizing => "false", :maxCount => Meeting.all.length, :fromDate => current_time}
    defaults.merge!(params.symbolize_keys)

    if defaults[:onlyUpcoming].to_s == "true" && defaults[:fromDate].to_i > current_time
      current_time = defaults[:fromDate].to_i
    end
    if defaults[:onlyUpcoming].to_s == "false"
      if defaults[:fromDate].to_i != current_time
        current_time = defaults[:fromDate].to_i
        puts "Test"
      else
      current_time = 0
      end
    end

    @meetings = Meeting.select("id, startDate, expectedDuration,user_id,title,description").where("private = :private AND startDate >= :start",
      {:private => false, :start => current_time}).limit(defaults[:maxCount].to_i)
    @meetings = Meeting.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {:status => "200 OK", :count => @meetings.length, :results => @meetings} }
    end
  end

  # GET /meetings/1
  # GET /meetings/1.json
  def show
    @meeting = Meeting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: {:status => "200 OK", :result => @meeting} }
    end
  end

  # GET /meetings/new
  # GET /meetings/new.json
  def new
    @meeting = Meeting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @meeting }
    end
  end

  # GET /meetings/1/edit
  def edit
    @meeting = Meeting.find(params[:id])
  end

  # POST /meetings
  # POST /meetings.json
  def create
    @meeting = Meeting.new(params[:meeting])

    respond_to do |format|
      if @meeting.save
        format.html { redirect_to @meeting, notice: 'Meeting was successfully created.' }
        format.json { render json: @meeting, status: :created, location: @meeting }
      else
        format.html { render action: "new" }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meetings/1
  # PUT /meetings/1.json
  def update
    @meeting = Meeting.find(params[:id])

    respond_to do |format|
      if @meeting.update_attributes(params[:meeting])
        format.html { redirect_to @meeting, notice: 'Meeting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1
  # DELETE /meetings/1.json
  def destroy
    @meeting = Meeting.find(params(:id))
    @meeting.destroy

    respond_to do |format|
      format.html { redirect_to meetings_url }
      format.json { head :no_content }
    end
  end

  private
  
  def authorized_meeting
    if !params[:id].nil?
      @meeting = Meeting.find(params[:id])
      puts "\n\n\n\n\nMeeting Private: "+ @meeting.private + "====\n"
      redirect_to meetings_path unless @meeting.private 
    end
  end
  
#   
  # def current_meeting=(meeting)
    # @current_meeting = meeting
  # end
#   
  # def current_user
    # @current_meeting ||=Meeting.find(params[:id])
  # end
  
  def authorized_users
    if !params[:id].nil?
      # puts "\n\n\n\n\nMeeting ID: "+ params[:id].to_s + "====\n"
      @meeting = Meeting.find(params[:id])
      @user = User.find(@meeting.user_id)
      redirect_to meetings_path, notice: "No premission" unless current_user == @user
    end
  end

  def get_current_time_since_unix
    DateTime.current.to_i
  end

end
