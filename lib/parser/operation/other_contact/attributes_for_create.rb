class Parser::Operation::OtherContact::AttributesForCreate < Parser::Operation::OtherContact::AttributesForUpdate
  map :get_attributes
  step :check_attributes
  map :add
  map :finish
end
