module FluxxRequestAmendment
  extend FluxxModuleHelper

  when_included do
    belongs_to :request, :polymorphic => true
  end

  class_methods do
  end

  instance_methods do
  end
end
