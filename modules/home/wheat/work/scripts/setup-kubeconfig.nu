#!/usr/bin/env nu

az account list |
  from json |
  where name =~ "^(Dev|Staging|Prod)$" |
  each {|subscription|
    az aks list --subscription $subscription.id | from json | each {|c|
      print "Getting credentials for: $c.name"
      az aks get-credentials --resource-group $c.resourceGroup --name $c.name --subscription $subscription.id --public-fqdn | ignore
    }
  } | ignore
