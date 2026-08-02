# Task7: Аудит и обеспечение соответствия политике безопасности контейнеров

## Структура

```
Task7/
├── 01-create-namespace.yaml          # Namespace с PodSecurity restricted
├── insecure-manifests/                # Небезопасные манифесты
│   ├── 01-privileged-pod.yaml
│   ├── 02-hostpath-pod.yaml
│   └── 03-root-user-pod.yaml
├── secure-manifests/                  # Исправленные манифесты
│   ├── 01-secure.yaml
│   ├── 02-secure.yaml
│   └── 03-secure.yaml
├── gatekeeper/                        # OPA Gatekeeper
│   ├── constraint-templates/
│   │   ├── privileged.yaml
│   │   ├── hostpath.yaml
│   │   └── runasnonroot.yaml
│   └── constraints/
│       ├── privileged.yaml
│       ├── hostpath.yaml
│       └── runasnonroot.yaml
├── verify/
│   ├── verify-admission.sh            # Проверка работы Admission Controller
│   └── validate-security.sh           # Проверка политик безопасности
├── audit-policy.yaml
└── README_FOR_REVIEWER.md
```

## Как проверить

### 1. Создать namespace
```bash
kubectl apply -f 01-create-namespace.yaml
```

### 2. Установить Gatekeeper
```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

### 3. Применить шаблоны и ограничения
```bash
kubectl apply -f gatekeeper/constraint-templates/
kubectl apply -f gatekeeper/constraints/
```

### 4. Запустить проверки
```bash
chmod +x verify/*.sh
./verify/verify-admission.sh
./verify/validate-security.sh
```

## Ожидаемые результаты

- **Небезопасные поды** -> отклонены (PodSecurity + Gatekeeper)
- **Безопасные поды** -> созданы успешно
- Gatekeeper активен и применяет ограничения

## Решения

| Нарушение | Исправление |
|-----------|-------------|
| `privileged: true` | `privileged: false`, `runAsNonRoot: true`, `readOnlyRootFilesystem: true` |
| `hostPath` | Заменён на `emptyDir` |
| `runAsUser: 0` | `runAsUser: 1000`, `runAsNonRoot: true` |
