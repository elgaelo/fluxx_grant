class FluxxGrantConvertAmountsToMoney < ActiveRecord::Migration
  def self.conversions
    {
      BudgetRequest => %w[amount_requested amount_recommended],
      FundingSourceAllocation => %w[amount],
      FundingSourceAllocationAuthority => %w[amount],
      FundingSource => %w[amount],
      RequestAmendment => %w[amount_recommended],
      RequestFundingSource => %w[funding_amount],
      RequestTransactionFundingSource => %w[amount],
      RequestTransaction => %w[amount_paid],
      Request => %w[amount_requested fund_expended_amount],
    }
  end

  def self.up
    conversions.each { |model, fields|
      fields.each { |field| model.update_all "#{field}=#{field}*100", "#{field} IS NOT NULL" }
    }
  end

  def self.down
    conversions.each { |model, fields|
      fields.each { |field| model.update_all "#{field}=#{field}/100", "#{field} IS NOT NULL" }
    }
  end
end
