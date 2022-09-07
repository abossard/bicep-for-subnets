param defaultRules array
param additionalRules array

output nsgProperties object = {
  securityRules: concat(defaultRules, additionalRules)
}
