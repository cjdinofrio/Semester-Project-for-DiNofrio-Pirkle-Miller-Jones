class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /events
  # GET /events.json
  def index
    @events = Event.all.reverse_order.paginate(page: params[:page],per_page: 5)
    authorize Event
  end

  # GET /events/1
  # GET /events/1.json
  def show
    authorize @event
  end

  # GET /events/new
  def new
    @event = current_user.events.build
    authorize @event
  end

  # GET /events/1/edit
  def edit
    authorize @event
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(event_params)
    authorize @event
    respond_to do |format|
      if @event.save
        current_user.likes = current_user.likes + 10
        current_user.update_attributes(:likes => current_user.likes)
        if current_user.likes >= 100
          if current_user.role.eql?"user"
            current_user.update_attributes(:role => 1)
          end
        end
        format.html { redirect_to newsfeed_index_path, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    authorize @event
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @user = User.find(@event.user_id)
    @user.likes = @user.likes - 10
    @user.update_attributes(:likes => @user.likes)
    if @user.likes < 100
      if @user.role.eql?"lead"
        @user.update_attributes(:role => 2)
      end
    end
    @event.destroy
    authorize @event
    respond_to do |format|
      format.html { redirect_to newsfeed_index_path, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :content, :day_of)
    end
end
