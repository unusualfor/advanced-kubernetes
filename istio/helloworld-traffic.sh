#!/bin/bash

while true
do
  kubectl exec -n demo "$(kubectl get pod -n demo -l version=v1 -o jsonpath='{.items[0].metadata.name}')" -c helloworld -- curl -sS helloworld:5000/hello
  sleep 0.5
done
