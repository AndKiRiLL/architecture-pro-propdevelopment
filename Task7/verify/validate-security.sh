#!/bin/bash

echo "=== ПРОВЕРКА ПОЛИТИК БЕЗОПАСНОСТИ ==="
echo ""

echo "1. Проверка Gatekeeper Constraint Templates:"
kubectl get constrainttemplates
echo ""

echo "2. Проверка Gatekeeper Constraints:"
kubectl get constraints
echo ""

echo "3. Проверка PodSecurity меток namespace:"
kubectl describe ns audit-zone | grep -A 3 "Labels"
echo ""

echo "4. Проверка всех подов в audit-zone:"
kubectl get pods -n audit-zone -o wide
echo ""

echo "5. Проверка безопасности подов:"
for pod in $(kubectl get pods -n audit-zone -o name); do
  echo "$pod:"
  kubectl get $pod -n audit-zone -o yaml | grep -A 5 "securityContext"
  echo ""
done

echo "=== ПРОВЕРКА ЗАВЕРШЕНА ==="