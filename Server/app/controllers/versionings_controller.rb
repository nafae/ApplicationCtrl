class VersioningsController < ApplicationController
  before_action :authenticate_user!, except: [:check]
  before_action :set_versioning, only: [:show, :edit, :update, :destroy]

  # cancan
  load_and_authorize_resource


  # GET /versionings
  def index
  end

  # GET /versionings/1
  def show
  end

  # GET /versionings/new
  def new
    @versioning = Versioning.new
  end

  # GET /versionings/1/edit
  def edit
  end

  # POST /versionings
  def create
    #remove_javascript(versioning_params[:content])
    @versioning = Versioning.new(versioning_params)

    if @versioning.save
      redirect_to @versioning, notice: 'Versioning was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /versionings/1
  def update
    #remove_javascript(versioning_params[:content])
    if @versioning.update(versioning_params)
      redirect_to @versioning, notice: 'Versioning was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /versionings/1
  def destroy
    @versioning.destroy
    redirect_to versionings_url, notice: 'Versioning was successfully destroyed.'
  end


  # HEADERS['version']


  # GET /versionings/check
  def check

    version_check_header =  Settings.version_check_http_label
    app_key = params[:app_key]
    version = params[:version]
    build = params[:build]
    response_format = params[:format] || :html

    response.header[version_check_header] = Settings.version_status[0].code # working

    status = :ok

    @description = 'Good to Go!'

    @application = App.none

    if (not app_key.nil?) && (not version.nil?) && (not build.nil?)
      @application = App.where(key: app_key).first

      if @application
        @versioning = Versioning.where(app_id: @application.id, profile: version, build: build).first
        if @versioning.nil?
          versioning_params = check_versioning_params.except(:app_key)
          versioning_params.merge!({:app_id => @application.id})
          @versioning = Versioning.create(versioning_params)

          if @versioning.save == false
            status = :internal_server_error
            @description = 'Not able to save the current version information into the db!'
          end

        else

          if @versioning.message?
            @description = Settings.version_check_http_label
          end

        end

        response.headers[version_check_header] = @versioning.status.to_s
      else
        @application = App.none
        @description = "No application found with the following app key #{app_key}"
        status = :unauthorized    # no app key found
      end

    else

      status = :bad_request
      @description = 'Please review the query parameters. Mandatory params: app_key, version, build. Optional: format'

    end


    if response_format == :html
      render layout: 'versioning', status: status  # URL is not well formed
    else
      render text: @description
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_versioning
      @versioning = Versioning.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def versioning_params
      params.require(:versioning).permit(:profile, :build, :status, :content, :app_id)
    end

    # API CALL for check params
    def check_versioning_params
      params.permit(:version, :build, :format, :app_key)
    end

    # Remove javascript from versioning content field
    def remove_javascript(html)

      doc = Nokogiri.HTML(html)

      doc.css('script').remove                             # Remove <script>…</script>
      puts doc                                             # Source w/o script blocks

      doc.xpath("//@*[starts-with(name(),'on')]").remove   # Remove on____ attributes
      puts doc                                             # Source w/o any JavaScript

    end
end
