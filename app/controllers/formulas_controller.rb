class FormulasController < ApplicationController
  before_filter :authorize_view, :only => [:index]
  before_filter :authorize_create, :only => [:new, :create]
  before_filter :authorize_update, :only => [:edit, :update]
  before_filter :authorize_delete, :only => [:destroy]
  
  def index
    @formulas = Formula.paginate(:per_page => 20, :page => params[:page], :include => [:finished_good], :order => "finished_goods.name")
  end
  
  def new
    @formula = Formula.new
    
    @formula.formula_items.build(:raw_material_type_id => RawMaterialType.find_by_code("CMR").id)
    11.times {@formula.formula_items.build}
  end
  
  def create
    @formula = Formula.new(params[:formula])
    @formula.creator = current_user
    if @formula.save
      flash[:notice] = "Formula saved successfully"
      redirect_to formulas_path
    else
      render :action => "new"
    end
  end
  
  def edit
    @formula = Formula.find(params[:id])
  end
  
  def update
    @formula = Formula.find(params[:id])
    @formula.updater = current_user
    if @formula.update_attributes(params[:formula])
      flash[:notice] = "Formula was updated successfully"
      redirect_to formulas_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @formula = Formula.find(params[:id])
    @formula.destroy
    flash[:notice] = "Formula was deleted successfully"
    redirect_to formulas_path
  end
  
  def update_finished_good
    @local = params[:local].to_i == 1
    @finished_good_id = params[:finished_good_id]
  end
  
  def update_raw_materials
    @index = params[:index]
    @raw_material_type = RawMaterialType.find(params[:raw_material_type_id])
    @raw_materials = @raw_material_type.raw_materials
  end
  
  protected
  
    def authorize_view
      authorize! :view, Formula
    end
    
    def authorize_create
      authorize! :create, Formula
    end
    
    def authorize_update
      authorize! :update, Formula
    end
    
    def authorize_delete
      authorize! :delete, Formula
    end
end
