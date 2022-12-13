grafana.ini:
  server:
    domain: monitoring.${hostname}
    root_url: "%(protocol)s://%(domain)s/grafana"
    serve_from_sub_path: true
ingress:
  enabled: true
  annotations: 
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - "monitoring.${hostname}"
  path: "/"
  tls:
  - hosts:
    - monitoring.${hostname}
    secretName: monitoring.${hostname}
datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus-server.prometheus.svc.cluster.local
     access: proxy
     isDefault: true
   - name: Loki
     type: loki
     url: http://loki-stack.loki.svc.cluster.local:3100
     access: proxy
dashboardProviders:
 dashboardproviders.yaml:
   apiVersion: 1
   providers:
   - name: 'default'
     orgId: 1
     folder: ''
     type: file
     disableDeletion: false
     editable: true
     options:
       path: /var/lib/grafana/dashboards/default

