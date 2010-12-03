class Admin::InfosController < AdminController
  # GET /admin_infos
  # GET /admin_infos.xml
  def index
    @infos = Info.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @infos }
    end
  end

  # GET /admin_infos/1
  # GET /admin_infos/1.xml
  def show
    @info = Info.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @info }
    end
  end

  # GET /admin_infos/new
  # GET /admin_infos/new.xml
  def new
    @info = Info.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @info }
    end
  end

  # GET /admin_infos/1/edit
  def edit
    @info = Info.find(params[:id])
  end

  # POST /admin_infos
  # POST /admin_infos.xml
  def create
    @info = Info.new(params[:info])

    respond_to do |format|
      if @info.save
        flash[:notice] = 'News was successfully created.'
        format.html { redirect_to([:admin, @info]) }
        format.xml  { render :xml => @info, :status => :created, :location => @info }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_infos/1
  # PUT /admin_infos/1.xml
  def update
    @info = Info.find(params[:id])

    respond_to do |format|
      if @info.update_attributes(params[:info])
        flash[:notice] = 'News was successfully updated.'
        format.html { redirect_to([:admin, @info]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_infos/1
  # DELETE /admin_infos/1.xml
  def destroy
    @info = Info.find(params[:id])
    @info.destroy

    respond_to do |format|
      format.html { redirect_to(admin_infos_url) }
      format.xml  { head :ok }
    end
  end
end
