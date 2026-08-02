#!/bin/bash

echo "=== ПРОВЕРКА ADMISSION CONTROLLER ==="
echo ""

echo "1. Проверка PodSecurity Admission"
echo "-------------------------------------------"

echo "Создание привилегированного пода (должна быть ошибка):"
kubectl apply -f insecure-manifests/01-privileged-pod.yaml 2>&1 | head -n 3
echo ""

echo "Создание пода с hostPath (должна быть ошибка):"
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml 2>&1 | head -n 3
echo ""

echo "Создание пода от root (должна быть ошибка):"
kubectl apply -f insecure-manifests/03-root-user-pod.yaml 2>&1 | head -n 3
echo ""

echo "2. Создание безопасных подов:"
kubectl apply -f secure-manifests/01-secure.yaml
kubectl apply -f secure-manifests/02-secure.yaml
kubectl apply -f secure-manifests/03-secure.yaml
echo ""

echo "3. Статус подов в audit-zone:"
kubectl get pods -n audit-zone