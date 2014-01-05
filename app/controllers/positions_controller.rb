class PositionsController < AuthController
  
  def index
    @officers = Hash.new
    position_map =  Positions.select("position, name, uname, contact, disp")
    position_map.each do |pos|
      unless pos.uname.empty?
        name = BrothersPersonal.find_by(uname: pos.uname).full_name
        year = BrothersMit.find_by(uname: pos.uname).year.to_s[2..3]
      end
      @officers[pos.position] = {uname: pos.uname, full_name: name, year: year, contact: pos.contact, name: pos.name, disp: pos.disp}
    end
  end
  
  def new
    @brothers = Array.new([])
    BrothersPersonal.select("uname","first_name, last_name").each do |brother|
      @brothers << [brother.full_name, brother.uname]
    end
    @brothers << ["",""]
    @brothers.sort!
    @officer = Positions.new
  end
  
  def edit
    @exec = exec
    @brothers = Array.new([])
    BrothersPersonal.select("uname","first_name, last_name").each do |brother|
      @brothers << [brother.full_name, brother.uname]
    end
    @brothers << ["",""]
    @brothers.sort!
    @officer = Positions.find_by(position: params[:id])
  end
  
  def create
    position = params.require(:positions).permit(:position, :name, :uname, :disp, :contact)
    @officer = Positions.new(position)
    if (position[:disp]=="1" && position[:contact].empty?) || !@officer.valid?
      @brothers = Array.new([])
      BrothersPersonal.select("uname","first_name, last_name").each do |brother|
        @brothers << [brother.full_name, brother.uname]
      end
      @brothers << ["",""]
      @brothers.sort!
      if @officer.valid?
        flash[:fail] = "Contact For: field is required to display on contact page"
      end
      render "new"
    else
      @officer.save
      flash[:success] = "Officer has been created"
      redirect_to positions_url
    end
  end
  
  def update
    @exec = exec
    position = params.require(:positions).permit(:position, :name, :uname, :disp, :contact)
    @officer = Positions.find_by(position: params[:id])
    @brothers = Array.new([])
    BrothersPersonal.select("uname","first_name, last_name").each do |brother|
      @brothers << [brother.full_name, brother.uname]
    end
    @brothers << ["",""]
    @brothers.sort!
    if position[:disp]=="1" && position[:contact].empty?
      flash[:fail] = "Contact For: field is required to display on contact page"
      render "edit"
    elsif @officer.update(position)
      flash[:success] = "Officer has been updated"
      redirect_to positions_url
    else
      render "edit"
    end
  end
  
  def destroy
    @officer = Positions.find_by(position: params[:id])
    @officer.destroy
    flash[:success] = "#{@officer.name} destroyed."
    redirect_to positions_url
  end
  
  def mass_edit
    @officers = Positions.select("position, name, uname")
    @brothers = Array.new([])
    BrothersPersonal.select("uname","first_name, last_name").each do |brother|
      @brothers << [brother.full_name, brother.uname]
    end
    @brothers.sort!
  end
  
  def mass_update
    params.require("officers").each do |position, officer|
      Positions.update_position(position, officer)
    end
    flash[:success] = "Officers updated"
    redirect_to positions_url
  end

 private
 
 def exec
   return ["beta", "sigma", "kappa", "zeta", "epsilon", "delta", "pi", "psi"]
 end

  
end