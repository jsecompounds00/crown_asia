class RawMaterialTypesController < ApplicationController

  def index
    if params[:search_text].blank?
      @raw_material_types = RawMaterialType.paginate(:per_page => 20, :page => params[:page], :order => "code")
    else
      @raw_material_types = RawMaterialType.paginate(:per_page => 20, :page => params[:page], :conditions => ["code LIKE ?", "%#{params[:search_text]}%"], :order => "code")
    end
  end
  
  def new
    @raw_material_type = RawMaterialType.new
  end
  
  def create
    @raw_material_type = RawMaterialType.new(params[:raw_material_type])
    @raw_material_type.creator = current_user
    if @raw_material_type.save
      flash[:notice] = "Raw Material Type saved successfully"
      redirect_to raw_material_types_path
    else
      render :action => "new"
    end
  end
  
  def edit
    @raw_material_type = RawMaterialType.find(params[:id])
  end
  
  def update
    @raw_material_type = RawMaterialType.find(params[:id])
    @raw_material_type.updater = current_user
    if @raw_material_type.update_attributes(params[:raw_material_type])
      flash[:notice] = "#{@raw_material_type.name} was updated successfully"
      redirect_to raw_material_types_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @raw_material_type = RawMaterialType.find(params[:id])
    @raw_material_type.destroy
    flash[:notice] = "#{@raw_material_type.name} was deleted successfully"
    redirect_to raw_material_types_path
  end

end
