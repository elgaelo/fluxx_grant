module FluxxRequestAmendment
  extend FluxxModuleHelper

  when_included do
    acts_as_money
    money :amount_recommended, :cents => :amount_recommended, :currency => false, :allow_nil => true
    belongs_to :request, :polymorphic => true
  end

  class_methods do
  end

  instance_methods do
  end
end
