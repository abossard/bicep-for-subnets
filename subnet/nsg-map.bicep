//
// This module is just here because nested loops require a resource or module.
//
@description('Default rules')
param defaultRules array

@description('Additional rules')
param additionalRules array

output nsgProperties object = {
  securityRules: concat(defaultRules, additionalRules)
}
