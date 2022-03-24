class TripsController < ApplicationController
  def index
    @trips = Trip.includes(:user).order('created_at DESC')
  end

  def new
    @trip = Trip.new
    @results = @trip.results.build
  end

  def create
    @trip = Trip.new(trip_params)
    if @trip.valid?
      @trip.save
      redirect_to trip_path(@trip)
    else
      @trip.valid?
      render :new
    end
  end

  def edit
    @trip = Trip.find(params[:id])
    go_back(@trip.user, trip_path(@trip))
  end

  def update
    @trip = Trip.find(params[:id])
    if @trip.update(trip_params)
      redirect_to trip_path(@trip)
    else
      render :edit
    end
  end

  def show
    @trip = Trip.find(params[:id])
    @results = @trip.results
    @comment = Comment.new
    @comments = @trip.comments.includes(:user)
  end

  def destroy
    trip = Trip.find(params[:id])
    trip.destroy
    redirect_to root_path
  end

  def search
    @result = Result.new
    if params[:keyword] &&  Result.search(params[:keyword])
      
      @results = Result.search(params[:keyword])
    
      months = [1,2,3,4,5,6,7,8,9,10,11,12]
      monthly_counts = []
      for month in 1..12 do
        c = 0
        @results.each do |result|
          if result.created_at.mon == month
            c += 1
          end
        end
        monthly_counts.append(c)
      end

      @chart = LazyHighCharts::HighChart.new('graph') do |c|
        c.title(text: "月ごとの#{params[:keyword]}の釣果数")
        c.xAxis(categories: months, title: {text: '月'})
        c.yAxis(title: {text: '件'})
        c.series(name: '釣果', data: monthly_counts)
        c.chart(type: 'column')
      end
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:title, :prefecture_id, :content, results_attributes: [:id, :fish_name, :image, :_destroy]).merge(user_id: current_user.id)
  end

  def go_back(owner, path)
    if current_user != owner
      redirect_to path
    end
  end
end
