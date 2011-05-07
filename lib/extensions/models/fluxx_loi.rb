module FluxxLoi
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id, :applicant, :organization, :email, :phone, :project_title]
  
  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.validates_presence_of   :applicant
    base.validates_presence_of   :organization
    base.validates_presence_of   :email

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    base.insta_realtime do |insta|
      insta.delta_attributes = SEARCH_ATTRIBUTES
      insta.updated_by_field = :updated_by_id
    end
    base.insta_multi
    base.insta_export do |insta|
      insta.filename = 'loi'
      insta.headers = [['Date Created', :date], ['Date Updated', :date]]
      insta.sql_query = "select created_at, updated_at
                from lois
                where id IN (?)"
    end
    base.insta_lock

    base.insta_template do |insta|
      insta.entity_name = 'loi'
      insta.add_methods []
      insta.remove_methods [:id]
    end

    base.insta_favorite
    base.insta_utc do |insta|
      insta.time_attributes = [] 
    end
    
#    base.insta_workflow do |insta|
      # insta.add_state_to_english :new, 'New Request'
      # insta.add_event_to_english :recommend_funding, 'Recommend Funding'
#    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
#    base.send :include, AASM
#    base.add_aasm
    base.add_sphinx if base.respond_to?(:sphinx_indexes) && !(base.connection.adapter_name =~ /SQLite/i)
  end
  

  module ModelClassMethods
    def add_aasm
      aasm_column :state
      aasm_initial_state :new
    end
    
    def add_sphinx
#      define_index :loi_first do
#        # fields
#
#
#        # attributes
#        has created_at, updated_at
#      end
    end
  end
  
  module ModelInstanceMethods
    def first_name
      applicant.gsub(/\s+/, ' ').split(' ').first
    end

    def last_name
      applicant.gsub(/\s+/, ' ').split(' ').last
    end

    def user_matches params = {}
      first = params && params[:first_name] ? params[:first_name] : first_name
      last = params && params[:last_name] ? params[:last_name] : last_name
      p params && params[:first_name]
      User.find(:all, :conditions => ["(first_name like ? and last_name like ?) and deleted_at is null", "%#{first}%", "%#{last}%"])
    end
  end
end