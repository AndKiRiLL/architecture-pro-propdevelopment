# Отчёт по результатам анализа Kubernetes Audit Log

## Подозрительные события

### 1. Доступ к секретам
- **Кто**: `system:serviceaccount:secure-ops:monitoring`
- **Где**: Попытка чтения default-token в namespace kube-system
- **Почему подозрительно**: ServiceAccount из secure-ops пытается получить доступ к системным секретам
- **Статус**: Запрос отклонён (403 Forbidden)

### 2. Привилегированные поды
- **Кто**: `kubernetes-admin`
- **Что**: Создание пода `privileged-pod` с `privileged: true`
- **Почему подозрительно**: Привилегированный под имеет доступ к узлу и может скомпрометировать хост
- **Статус**: Успешно создан

### 3. Использование kubectl exec в чужом поде
- **Кто**: `kubernetes-admin`
- **Что**: Выполнение `cat /etc/resolv.conf` в поде coredns
- **Почему подозрительно**: Исполнение команд в системных подах через exec
- **Статус**: Успешно выполнено

### 4. Создание RoleBinding с правами cluster-admin
- **Кто**: `kubernetes-admin`
- **Что**: RoleBinding `escalate-binding` для ServiceAccount monitoring с ClusterRole cluster-admin
- **К чему привело**: ServiceAccount monitoring получил полные права администратора
- **Статус**: Создано успешно

### 5. Попытка удаления audit-policy
- **Кто**: `admin`
- **Что**: Попытка удалить audit-policy.yaml
- **Возможные последствия**: Отключение аудита при успешном удалении
- **Статус**: Не удалось (файл на хосте)

## Выводы

**Кластер скомпрометирован**, потому что:
1. Создан привилегированный под
2. Создан RoleBinding с cluster-admin
3. Была попытка отключить аудит