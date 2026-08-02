#!/usr/bin/env python3
import json
import sys

def filter_events(log_path):
    suspicious = []
    with open(log_path, 'r') as f:
        for line in f:
            try:
                event = json.loads(line.strip())
                obj = event.get('objectRef', {})
                verb = event.get('verb', '')
                if obj.get('resource') == 'secrets' and verb == 'get':
                    suspicious.append(event)
                if obj.get('resource') == 'pods' and verb == 'create':
                    if event.get('requestObject', {}).get('spec', {}).get('containers', [{}])[0].get('securityContext', {}).get('privileged') == True:
                        suspicious.append(event)
                if obj.get('subresource') == 'exec' and verb == 'create':
                    suspicious.append(event)
                if obj.get('resource') == 'rolebindings' and verb == 'create':
                    if 'cluster-admin' in str(event):
                        suspicious.append(event)
                if 'audit' in str(obj).lower() and verb == 'delete':
                    suspicious.append(event)
            except:
                continue
    return suspicious

if __name__ == '__main__':
    log_file = sys.argv[1] if len(sys.argv) > 1 else 'audit.log'
    events = filter_events(log_file)
    
    safe_events = []
    for e in events:
        safe_events.append({
            "timestamp": e.get('stageTimestamp', ''),
            "user": e.get('user', {}).get('username', 'unknown'),
            "verb": e.get('verb', ''),
            "resource": e.get('objectRef', {}),
            "response_code": e.get('responseStatus', {}).get('code', 0)
        })
    
    with open('audit-extract.json', 'w') as f:
        json.dump(safe_events, f, indent=2)
    
    print(f"Найдено {len(events)} подозрительных событий")
    print("Выжимка сохранена в audit-extract.json")