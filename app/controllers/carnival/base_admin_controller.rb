module Carnival
  class BaseAdminController < InheritedResources::Base
    respond_to :html, :json
    before_filter :authenticate_admin_user!


    def generate_datatable
      model_presenter = instantiate_presenter
      Carnival::GenericDatatable.new(view_context, instantiate_model(model_presenter), self, model_presenter)
    end

    def index
      @datatable = generate_datatable
      @advanced_search = params["advanced_search"] if params["advanced_search"].present?

      if params[:special_scope].present?
        presenter = @datatable.presenter
        presenter.parse_special_scope params[:special_scope]
      end

      respond_to do |format|
        format.html do |render|
          render 'index' and return
        end
        format.json do |render|
          if params[:list_scope]
            render(json: @datatable.as_list) and return
          else
            render(json: @datatable) and return
          end
        end
        format.csv do
          render text: @datatable.as_csv.encode("utf-16le") and return
        end
        format.pdf do
          render :pdf => t("#{@datatable.model.to_s.underscore}.lista") , :template => 'carnival/index.pdf.haml',  :show_as_html => params[:debug].present? and return
        end
      end
    end

    def show
      @model_presenter = instantiate_presenter
      show! do |format|
        format.html do |render|
          render 'show'
        end
      end
    end

    def new
      @model_presenter = instantiate_presenter
      new! do |format|
        @model = instance_variable_get("@#{controller_name.classify.underscore}")
        format.html do |render|
          render 'new'
        end
      end
    end

    def edit
      @model_presenter = instantiate_presenter
      edit! do |format|
        @model = instance_variable_get("@#{controller_name.classify.underscore}")
        format.html do |render|
          render 'edit'
        end
      end
    end

    def create
      @model_presenter = instantiate_presenter
      create! do |success, failure|
        success.html{ redirect_to @model_presenter.model_path(:index), :notice => I18n.t("messages.created") }
        failure.html do |render|
          @model = instance_variable_get("@#{controller_name.classify.underscore}")
          render 'new'
        end
      end
    end

    def update
      @model_presenter = instantiate_presenter
      update! do |success, failure|
        success.html{ redirect_to @model_presenter.model_path(:index), :notice => I18n.t("messages.updated") }
        failure.html do |render|
          @model = instance_variable_get("@#{controller_name.classify.underscore}")
          render 'edit'
        end
      end
    end

    def render_popup partial
      @application_popup = partial
      render 'layouts/shared/render_popup' and return
    end

    def load_dependent_select_options
      presenter = params[:presenter].constantize.send(:new, :controller => self)
      model = presenter.relation_model(params[:field].gsub("_id", "").to_sym)
      @options = model.list_for_select(add_empty_option: true, query: ["#{params[:dependency_field]} = ?", params[:dependency_value]])
      render layout: nil
    end

    private

    def instantiate_model(presenter)
      presenter.full_model_name.classify.constantize
    end

    def instantiate_presenter
      namespace = extract_namespace
      if namespace.present?
        "#{extract_namespace}::#{controller_name.classify}Presenter".constantize.send(:new, :controller => self)
      else
        "#{controller_name.classify}Presenter".constantize.send(:new, :controller => self)
      end
    end

    def extract_namespace
      namespace = ""
      arr = self.class.to_s.split("::")
      namespace = arr[0] if arr.size > 1
      namespace
    end

    def after_sign_in_path_for(user)
      session[:admin_user_id] = user.id
      admin_root_path
    end

    def after_sign_out_path_for(user)
      session[:admin_user_id] = nil
      root_path
    end
  end

  def authenticate_admin_user!
    redirect_to admin_root_path if current_admin_user.nil?
  end
end
