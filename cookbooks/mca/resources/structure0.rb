actions :create
default_action :create

attribute :dest, :name_attribute => true, :kind_of => String, :required => true
attribute :mod_name , :kind_of => String, :required => true

attr_accessor :exists

