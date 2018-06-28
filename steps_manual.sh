
NAMESPACE=default
REGISTRY=mycluster.icp:8500

# Install Container Structure test
curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 && chmod +x container-structure-test-linux-amd64 && sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test


docker build -t mycluster.icp:8500/default/hello-container:latest .
docker images | grep hello-container
docker login --username=admin --password=admin mycluster.icp:8500
docker push  mycluster.icp:8500/default/hello-container:latest
kubectl get images
container-structure-test  -test.v   -image \${REGISTRY}/\${NAMESPACE}/hello-container:latest /opt/git/hellocontainer/hello-container-test.yaml

helm install ./hellocontainer-chart/ -n hellocontainer --tls
helm upgrade hello-container ./hellocontainer-chart/ --set image.repository=\${REGISTRY}/\${NAMESPACE}/hello-container --set image.tag=latest -n hellocontainer --tls

helm list --tls | grep hello

kubectl get services | grep hello

