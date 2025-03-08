class Parser::Operation::ContactPerson::AttributesForCreate < Parser::Operation::ContactPerson::AttributesForUpdate
  map :get_attributes
  step :check_attributes
  map :add
  map :finish
end
