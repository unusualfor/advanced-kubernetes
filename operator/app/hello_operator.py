import kopf
import kubernetes.client as k8s

def configmap_body(name, namespace, greeting):
    return k8s.V1ConfigMap(
        metadata=k8s.V1ObjectMeta(
            name=f"hello-{name}",
            namespace=namespace,
            labels={"app": "hello-operator"}
        ),
        data={"greeting": greeting}
    )

@kopf.on.create('unusualfor.com', 'v1', 'hellos')
@kopf.on.update('unusualfor.com', 'v1', 'hellos')
def reconcile_hello(spec, name, namespace, **kwargs):
    person = spec.get('name', 'world')
    greeting = f"Hello, {person}!"
    api = k8s.CoreV1Api()
    body = configmap_body(name, namespace, greeting)
    try:
        api.replace_namespaced_config_map(body.metadata.name, namespace, body)
    except k8s.rest.ApiException:
        api.create_namespaced_config_map(namespace, body)

@kopf.on.delete('unusualfor.com', 'v1', 'hellos')
def delete_hello(spec, name, namespace, **kwargs):
    api = k8s.CoreV1Api()
    try:
        api.delete_namespaced_config_map(f"hello-{name}", namespace)
    except k8s.rest.ApiException:
        pass  # Already deleted

@kopf.timer('unusualfor.com', 'v1', 'hellos', interval=60)
def periodic_reconcile(spec, name, namespace, **kwargs):
    # Optionally, re-check and re-create the ConfigMap every minute
    person = spec.get('name', 'world')
    greeting = f"Hello, {person}!"
    api = k8s.CoreV1Api()
    body = configmap_body(name, namespace, greeting)
    try:
        api.read_namespaced_config_map(body.metadata.name, namespace)
    except k8s.rest.ApiException:
        api.create_namespaced_config_map(namespace, body)
