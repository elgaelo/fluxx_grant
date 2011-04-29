module FluxxGrantModelDocumentTypesController
  def self.included(base)
    base.send :include, FluxxModelDocumentTypesController
    base.insta_index ModelDocumentType do |insta|
      insta.pre do |controller_dsl|
        if params[:model_id] && params[:model_type]
          klass = Kernel.const_get params[:model_type] rescue nil
          if klass && klass.extract_classes(klass).any?{|cur_klass| cur_klass == Request} && (request_model = klass.find(params[:model_id]))
            self.pre_models = ModelDocumentType.where(:model_type => klass.name).where(['if(program_id is not null, program_id = ?, true) AND 
              if(sub_program_id is not null, program_id = ?, true) AND 
                if(initiative_id is not null, initiative_id = ?, true) AND 
                  if(sub_initiative_id is not null, initiative_id = ?, true)',request_model.program_id, request_model.sub_program_id, request_model.initiative_id, request_model.sub_initiative_id]).all
          end
        end
          
      end
    end
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end
end